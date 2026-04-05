import { useEffect, useMemo, useState } from 'react';
import { useLocation } from 'react-router-dom';
import partnerApi from '@/api/partner.api';
import clienteApi from '@/api/cliente.api';

function readCache(audience, id) {
  try {
    const raw = sessionStorage.getItem(`entity:${audience}:${id}`);
    return raw ? JSON.parse(raw) : null;
  } catch { return null; }
}

function writeCache(audience, id, entity) {
  try {
    sessionStorage.setItem(`entity:${audience}:${id}`, JSON.stringify(entity));
  } catch { /* ignore */ }
}

export default function useEntityName(audience, id, fallbackName = '') {
  const location = useLocation();
  const [entity, setEntity] = useState(null);

  // Router state — set when user navigates from the EntityDropdown
  const locationState = useMemo(() => {
    const s = location.state;
    if (!s || String(s.id) !== String(id) || s.audience !== audience) return null;
    return { id: s.id, nombre: s.nombre, estado: s.estado };
  }, [audience, id, location.state]);

  useEffect(() => {
    // 1. Router state (instant — user clicked the dropdown)
    if (locationState?.nombre) {
      setEntity(locationState);
      writeCache(audience, id, locationState);
      return;
    }

    // 2. Session cache (same browser tab, different render)
    const cached = readCache(audience, id);
    if (cached?.nombre) {
      setEntity(cached);
      return;
    }

    // 3. Fetch via dedicated /info endpoint (works on direct URL navigation)
    if (!id) return;
    const controller = new AbortController();

    const fetchFn = audience === 'partner'
      ? () => partnerApi.getInfo(id, controller.signal)
      : () => clienteApi.getInfo(id, controller.signal);

    fetchFn()
      .then((result) => {
        if (controller.signal.aborted) return;
        if (result?.nombre) {
          const resolved = { id: result.id, nombre: result.nombre, estado: result.estado };
          setEntity(resolved);
          writeCache(audience, id, resolved);
        }
      })
      .catch(() => { /* show fallback */ });

    return () => controller.abort();
  }, [audience, id, locationState]);

  return {
    name: entity?.nombre ?? fallbackName,
    status: entity?.estado ?? null,
  };
}
