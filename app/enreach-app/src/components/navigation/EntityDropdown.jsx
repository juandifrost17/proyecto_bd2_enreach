import { useCallback, useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronDown, Search } from 'lucide-react';
import partnerApi from '@/api/partner.api';
import clienteApi from '@/api/cliente.api';

const STATUS_COLORS = {
  ACTIVO:   { bg: 'var(--color-status-ok-bg)',       text: 'var(--color-status-ok)'       },
  INACTIVO: { bg: 'var(--color-status-critical-bg)', text: 'var(--color-status-critical)' },
};

function EntityDropdown({ audience, currentName, currentId }) {
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const [entities, setEntities] = useState([]);
  const [filter, setFilter] = useState('');
  const [loading, setLoading] = useState(false);
  const ref = useRef(null);
  const fetchedRef = useRef(false);

  // Fetch all entities via /all endpoint — no query param needed, no empty-string issue
  const fetchAll = useCallback(async () => {
    if (fetchedRef.current) return;
    fetchedRef.current = true;
    setLoading(true);
    try {
      const results = audience === 'partner'
        ? await partnerApi.getAll()
        : await clienteApi.getAll();
      setEntities(Array.isArray(results) ? results : []);
    } catch {
      fetchedRef.current = false; // allow retry on error
      setEntities([]);
    } finally {
      setLoading(false);
    }
  }, [audience]);

  const handleOpen = () => {
    const next = !open;
    setOpen(next);
    if (next) fetchAll();
  };

  // Close on outside click
  useEffect(() => {
    function onDown(e) {
      if (ref.current && !ref.current.contains(e.target)) setOpen(false);
    }
    document.addEventListener('mousedown', onDown);
    return () => document.removeEventListener('mousedown', onDown);
  }, []);

  // Reset on audience change
  useEffect(() => {
    setEntities([]);
    setFilter('');
    setOpen(false);
    fetchedRef.current = false;
  }, [audience]);

  const filtered = filter.trim()
    ? entities.filter((e) => e.nombre.toLowerCase().includes(filter.toLowerCase()))
    : entities;

  const handleSelect = (item) => {
    setOpen(false);
    setFilter('');
    const basePath = audience === 'partner' ? '/partner' : '/cliente';
    navigate(`${basePath}/${item.id}`, {
      state: { audience, id: item.id, nombre: item.nombre, estado: item.estado },
    });
  };

  const label = audience === 'partner' ? 'partner' : 'cliente';

  return (
    <div ref={ref} style={{ position: 'relative' }}>
      {/* Trigger */}
      <button
        type="button"
        onClick={handleOpen}
        style={{
          display: 'flex', alignItems: 'center', gap: '0.5rem',
          padding: '0.42rem 0.85rem',
          border: `1.5px solid ${open ? 'var(--color-primary)' : 'var(--color-chart-grid)'}`,
          borderRadius: 10,
          background: 'var(--color-surface-lowest)',
          color: 'var(--color-text-heading)',
          fontSize: '0.82rem', fontWeight: 500,
          cursor: 'pointer', transition: 'border-color 0.15s',
          minWidth: 190, maxWidth: 280,
        }}
      >
        <span style={{ flex: 1, textAlign: 'left', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {currentName || `Seleccionar ${label}`}
        </span>
        <ChevronDown size={14} style={{
          flexShrink: 0,
          transform: open ? 'rotate(180deg)' : 'none',
          transition: 'transform 0.2s',
          color: 'var(--color-text-muted)',
        }} />
      </button>

      {/* Dropdown panel */}
      {open && (
        <div style={{
          position: 'absolute', top: 'calc(100% + 6px)', right: 0, zIndex: 200,
          background: 'var(--color-surface-lowest)',
          border: '1px solid var(--color-chart-grid)',
          borderRadius: 12, boxShadow: 'var(--shadow-float)',
          minWidth: 260, maxWidth: 340, overflow: 'hidden',
        }}>
          {/* Filter input */}
          <div style={{
            padding: '0.5rem 0.75rem',
            borderBottom: '1px solid var(--color-chart-grid)',
            display: 'flex', alignItems: 'center', gap: '0.5rem',
          }}>
            <Search size={13} style={{ color: 'var(--color-text-muted)', flexShrink: 0 }} />
            <input
              type="text"
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              placeholder={`Filtrar ${label}…`}
              autoFocus
              style={{
                border: 'none', outline: 'none', background: 'transparent',
                fontSize: '0.8rem', color: 'var(--color-text-body)', width: '100%',
              }}
            />
          </div>

          {/* List */}
          <div style={{ maxHeight: 220, overflowY: 'auto' }}>
            {loading && (
              <p style={{ padding: '0.75rem 1rem', fontSize: '0.8rem', color: 'var(--color-text-muted)', textAlign: 'center' }}>
                Cargando…
              </p>
            )}
            {!loading && filtered.length === 0 && (
              <p style={{ padding: '0.75rem 1rem', fontSize: '0.8rem', color: 'var(--color-text-muted)', textAlign: 'center' }}>
                Sin resultados
              </p>
            )}
            {filtered.map((item) => {
              const sc = STATUS_COLORS[item.estado?.toUpperCase()] ?? STATUS_COLORS.ACTIVO;
              const isCurrent = String(item.id) === String(currentId);
              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => handleSelect(item)}
                  style={{
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                    width: '100%', padding: '0.52rem 0.9rem',
                    background: isCurrent ? 'var(--color-primary-light)' : 'transparent',
                    border: 'none', borderBottom: '1px solid var(--color-surface-low)',
                    cursor: 'pointer', textAlign: 'left', gap: '0.5rem',
                  }}
                >
                  <span style={{
                    fontSize: '0.82rem', fontWeight: isCurrent ? 600 : 400,
                    color: isCurrent ? 'var(--color-primary)' : 'var(--color-text-heading)',
                    overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                  }}>
                    {item.nombre}
                  </span>
                  <span style={{
                    fontSize: '0.68rem', fontWeight: 600, padding: '2px 6px',
                    borderRadius: 4, background: sc.bg, color: sc.text, flexShrink: 0,
                  }}>
                    {item.estado}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

export default EntityDropdown;
