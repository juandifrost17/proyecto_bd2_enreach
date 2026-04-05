import { get, withPeriodParams } from '@/api/client';

function assertClienteId(id) {
  if (id === null || id === undefined || id === '') {
    throw new Error('clienteApi requires a cliente id.');
  }
}

function buildPath(id, resource) {
  assertClienteId(id);
  return `/cliente/${id}${resource}`;
}

function buildParams(period) {
  return withPeriodParams(period);
}

export const clienteApi = {
  getKpis(id, period, signal) {
    return get(buildPath(id, '/kpis'), { params: buildParams(period), signal });
  },

  // Contexto
  getTendenciaComunicaciones(id, period, signal) {
    return get(buildPath(id, '/reporte/tendencia-comunicaciones'), {
      params: { anio: period?.anio ?? 2023 },
      signal,
    });
  },

  getCostoPorInteraccion(id, period, signal) {
    return get(buildPath(id, '/reporte/costo-por-interaccion'), { params: buildParams(period), signal });
  },

  getUsoVsCapacidad(id, period, signal) {
    return get(buildPath(id, '/reporte/20-uso-vs-capacidad'), { params: buildParams(period), signal });
  },

  getSaturacionHoraria(id, period, signal) {
    return get(buildPath(id, '/reporte/21-saturacion-horaria'), { params: buildParams(period), signal });
  },

  getEmbudoContactoFilial(id, period, signal) {
    return get(buildPath(id, '/reporte/embudo-contacto-filial'), { params: buildParams(period), signal });
  },

  // Detalle granular
  getEstadoPagos(id, period, signal) {
    return get(buildPath(id, '/reporte/19-estado-pagos'), { params: buildParams(period), signal });
  },

  getUsuariosNoContestacion(id, period, signal) {
    return get(buildPath(id, '/reporte/22-usuarios-no-contestacion'), { params: buildParams(period), signal });
  },

  getGruposColaboracion(id, period, signal) {
    return get(buildPath(id, '/reporte/grupos-colaboracion'), { params: buildParams(period), signal });
  },

  getHealth(signal) {
    return get('/cliente/health', { signal });
  },

  // All clientes for dropdown (no query param)
  getAll(signal) {
    return get('/cliente/all', { signal });
  },

  // Resolve name + estado by ID for direct URL navigation
  getInfo(id, signal) {
    return get(`/cliente/${id}/info`, { signal });
  },
};

export default clienteApi;
