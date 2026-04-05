import { useCallback, useEffect, useMemo, useReducer, useRef, useState } from 'react';
import clienteApi from '@/api/cliente.api';
import enreachApi from '@/api/enreach.api';
import partnerApi from '@/api/partner.api';
import { isEmptyData } from '@/hooks/useFetch';

function createReportState(resources, previousState, preserveDataOnRefetch = true) {
  return resources.reduce((accumulator, resource) => {
    const previous = previousState?.[resource.key];
    accumulator[resource.key] = {
      key: resource.key, label: resource.label, order: resource.order ?? 0,
      data: preserveDataOnRefetch ? previous?.data ?? null : null,
      rawData: preserveDataOnRefetch ? previous?.rawData ?? null : null,
      error: null, loading: true, empty: false, status: 'loading',
    };
    return accumulator;
  }, {});
}

function resolveFinalReportState(resource, result) {
  if (result.status === 'fulfilled') {
    const rawData = result.value;
    const data = typeof resource.mapData === 'function' ? resource.mapData(rawData) : rawData;
    return {
      key: resource.key, label: resource.label, order: resource.order ?? 0,
      data, rawData, error: null, loading: false,
      empty: isEmptyData(data), status: isEmptyData(data) ? 'empty' : 'success',
    };
  }
  return {
    key: resource.key, label: resource.label, order: resource.order ?? 0,
    data: null, rawData: null, error: result.reason,
    loading: false, empty: false, status: 'error',
  };
}

export function useDashboardReports(resources = [], deps = [], options = {}) {
  const { enabled = true, preserveDataOnRefetch = true } = options;
  const requestIdRef = useRef(0);
  const mountedRef = useRef(true);
  const [reloadKey, forceReload] = useReducer((value) => value + 1, 0);
  const [reports, setReports] = useState(() => {
    if (!enabled || resources.length === 0) return {};
    return createReportState(resources, undefined, false);
  });

  useEffect(() => { return () => { mountedRef.current = false; }; }, []);

  useEffect(() => {
    if (!enabled || resources.length === 0) { setReports({}); return undefined; }
    const controller = new AbortController();
    const requestId = ++requestIdRef.current;
    setReports((prev) => createReportState(resources, prev, preserveDataOnRefetch));
    Promise.allSettled(
      resources.map((r) => Promise.resolve().then(() => r.fetcher(controller.signal)))
    ).then((results) => {
      if (!mountedRef.current || requestId !== requestIdRef.current) return;
      const next = resources.reduce((acc, r, i) => {
        acc[r.key] = resolveFinalReportState(r, results[i]);
        return acc;
      }, {});
      setReports(next);
    });
    return () => controller.abort();
  }, [enabled, preserveDataOnRefetch, reloadKey, resources, ...deps]);

  const orderedReports = useMemo(
    () => Object.values(reports).sort((a, b) => a.order - b.order), [reports]
  );
  const summary = useMemo(() => ({
    isIdle: enabled && resources.length === 0,
    isLoading: orderedReports.some((r) => r.loading),
    isLoaded: orderedReports.length > 0 && orderedReports.every((r) => !r.loading),
    hasErrors: orderedReports.some((r) => r.status === 'error'),
    allEmpty: orderedReports.length > 0 && orderedReports.every((r) => r.status === 'empty'),
    errors: orderedReports.filter((r) => r.status === 'error'),
  }), [enabled, orderedReports, resources.length]);
  const refetch = useCallback(() => { forceReload(); }, []);
  return { reports, orderedReports, refetch, ...summary };
}

// ── ENREACH ──────────────────────────────────────────────────────────────────
function createEnreachResources(period) {
  return [
    { key: 'kpis', label: 'KPIs', order: 1, fetcher: (s) => enreachApi.getKpis(period, s) },
    { key: 'facturadoVsCobrado', label: 'Facturado vs Cobrado', order: 2, fetcher: (s) => enreachApi.getFacturadoVsCobrado(period, s) },
    { key: 'riesgoFinanciero', label: 'Riesgo financiero', order: 3, fetcher: (s) => enreachApi.getRiesgoFinanciero(period, s) },
    { key: 'demandaHoraria', label: 'Demanda horaria', order: 4, fetcher: (s) => enreachApi.getDemandaHoraria(period, s) },
    { key: 'calidadLlamadas', label: 'Calidad de llamadas', order: 5, fetcher: (s) => enreachApi.getCalidadLlamadas(period, s) },
    { key: 'saludMensajeria', label: 'Salud mensajería', order: 6, fetcher: (s) => enreachApi.getSaludMensajeria(period, s) },
    { key: 'tendenciaFacturacion', label: 'Tendencia facturación', order: 7, fetcher: (s) => enreachApi.getTendenciaFacturacion(period, s) },
    { key: 'revenuePorPais', label: 'Revenue por país', order: 8, fetcher: (s) => enreachApi.getRevenuePorPais(period, s) },
    { key: 'scorecard', label: 'Scorecard', order: 9, fetcher: (s) => enreachApi.getScorecard(period, s) },
    { key: 'vencimientosAcuerdos', label: 'Vencimientos acuerdos', order: 10, fetcher: (s) => enreachApi.getVencimientosAcuerdos(period, s) },
  ];
}

// ── PARTNER ──────────────────────────────────────────────────────────────────
function createPartnerResources(id, period) {
  return [
    { key: 'kpis', label: 'KPIs', order: 1, fetcher: (s) => partnerApi.getKpis(id, period, s) },
    { key: 'facturadoVsCobrado', label: 'Facturado vs cobrado', order: 2, fetcher: (s) => partnerApi.getFacturadoVsCobrado(id, period, s) },
    { key: 'agingCartera', label: 'Aging cartera', order: 3, fetcher: (s) => partnerApi.getAgingCartera(id, period, s) },
    { key: 'usoVsPlan', label: 'Uso vs plan', order: 4, fetcher: (s) => partnerApi.getUsoVsPlan(id, period, s) },
    { key: 'deterioroLlamadas', label: 'Deterioro de llamadas', order: 5, fetcher: (s) => partnerApi.getDeterioroLlamadas(id, period, s) },
    { key: 'calidadMensajeria', label: 'Calidad mensajería', order: 6, fetcher: (s) => partnerApi.getCalidadMensajeria(id, period, s) },
    { key: 'crecimientoNeto', label: 'Crecimiento neto', order: 7, fetcher: (s) => partnerApi.getCrecimientoNetoClientes(id, period, s) },
    { key: 'mesaOperativa', label: 'Mesa operativa', order: 8, fetcher: (s) => partnerApi.getMesaOperativa(id, period, s) },
    { key: 'vencimientosContratos', label: 'Vencimientos contratos', order: 9, fetcher: (s) => partnerApi.getVencimientosContratos(id, period, s) },
  ];
}

// ── CLIENTE ──────────────────────────────────────────────────────────────────
function createClienteResources(id, period) {
  return [
    { key: 'kpis', label: 'KPIs', order: 1, fetcher: (s) => clienteApi.getKpis(id, period, s) },
    { key: 'tendenciaComunicaciones', label: 'Tendencia comunicaciones', order: 2, fetcher: (s) => clienteApi.getTendenciaComunicaciones(id, period, s) },
    { key: 'costoPorInteraccion', label: 'Costo por interacción', order: 3, fetcher: (s) => clienteApi.getCostoPorInteraccion(id, period, s) },
    { key: 'usoVsCapacidad', label: 'Uso vs capacidad', order: 4, fetcher: (s) => clienteApi.getUsoVsCapacidad(id, period, s) },
    { key: 'saturacionHoraria', label: 'Saturación horaria', order: 5, fetcher: (s) => clienteApi.getSaturacionHoraria(id, period, s) },
    { key: 'embudoContactoFilial', label: 'Embudo contacto filial', order: 6, fetcher: (s) => clienteApi.getEmbudoContactoFilial(id, period, s) },
    { key: 'estadoPagos', label: 'Estado de pagos', order: 7, fetcher: (s) => clienteApi.getEstadoPagos(id, period, s) },
    { key: 'usuariosNoContestacion', label: 'Usuarios no contestación', order: 8, fetcher: (s) => clienteApi.getUsuariosNoContestacion(id, period, s) },
    { key: 'gruposColaboracion', label: 'Grupos colaboración', order: 9, fetcher: (s) => clienteApi.getGruposColaboracion(id, period, s) },
  ];
}

export function useEnreachDashboardReports(period, options = {}) {
  const resources = useMemo(() => createEnreachResources(period), [period]);
  return useDashboardReports(resources, [period?.anio, period?.periodo, period?.tipoFiltro], options);
}

export function usePartnerDashboardReports(id, period, options = {}) {
  const resources = useMemo(() => createPartnerResources(id, period), [id, period]);
  return useDashboardReports(resources, [id, period?.anio, period?.periodo, period?.tipoFiltro], {
    ...options, enabled: Boolean(id) && (options.enabled ?? true),
  });
}

export function useClienteDashboardReports(id, period, options = {}) {
  const resources = useMemo(() => createClienteResources(id, period), [id, period]);
  return useDashboardReports(resources, [id, period?.anio, period?.periodo, period?.tipoFiltro], {
    ...options, enabled: Boolean(id) && (options.enabled ?? true),
  });
}
