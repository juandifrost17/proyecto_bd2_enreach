import { get, withPeriodParams } from '@/api/client';

function assertPartnerId(id) {
  if (id === null || id === undefined || id === '') {
    throw new Error('partnerApi requires a partner id.');
  }
}

function buildPath(id, resource) {
  assertPartnerId(id);
  return `/partner/${id}${resource}`;
}

function buildParams(period) {
  return withPeriodParams(period);
}

export const partnerApi = {
  getKpis(id, period, signal) {
    return get(buildPath(id, '/kpis'), { params: buildParams(period), signal });
  },

  // Reportes contexto (4 params)
  getFacturadoVsCobrado(id, period, signal) {
    return get(buildPath(id, '/reporte/9-facturado-vs-cobrado'), { params: buildParams(period), signal });
  },

  getAgingCartera(id, period, signal) {
    return get(buildPath(id, '/reporte/10-aging-cartera'), { params: buildParams(period), signal });
  },

  getUsoVsPlan(id, period, signal) {
    return get(buildPath(id, '/reporte/11-uso-vs-plan'), { params: buildParams(period), signal });
  },

  getDeterioroLlamadas(id, period, signal) {
    return get(buildPath(id, '/reporte/14-deterioro-llamadas'), { params: buildParams(period), signal });
  },

  getCalidadMensajeria(id, period, signal) {
    return get(buildPath(id, '/reporte/15-calidad-mensajeria'), { params: buildParams(period), signal });
  },

  // Tendencia (2 params)
  getCrecimientoNetoClientes(id, period, signal) {
    return get(buildPath(id, '/reporte/crecimiento-neto-clientes'), {
      params: { anio: period?.anio ?? 2023 },
      signal,
    });
  },

  // Detalle granular
  getMesaOperativa(id, period, signal) {
    return get(buildPath(id, '/reporte/16-mesa-operativa'), { params: buildParams(period), signal });
  },

  getVencimientosContratos(id, period, signal) {
    return get(buildPath(id, '/reporte/vencimientos-contratos'), { signal });
  },

  getHealth(signal) {
    return get('/partner/health', { signal });
  },

  // All partners for dropdown (no query param)
  getAll(signal) {
    return get('/partner/all', { signal });
  },

  // Resolve name + estado by ID for direct URL navigation
  getInfo(id, signal) {
    return get(`/partner/${id}/info`, { signal });
  },
};

export default partnerApi;
