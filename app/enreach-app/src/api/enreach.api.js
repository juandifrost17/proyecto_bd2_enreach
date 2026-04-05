import { get, withPeriodParams } from '@/api/client';

function buildParams(period, idEntidad) {
  return {
    ...withPeriodParams(period),
    idEntidad,
  };
}

export const enreachApi = {
  getKpis(period, signal, idEntidad) {
    return get('/enreach/kpis', { params: buildParams(period, idEntidad), signal });
  },

  // Reportes contexto (4 params)
  getFacturadoVsCobrado(period, signal, idEntidad) {
    return get('/enreach/reporte/1-facturado-vs-cobrado', { params: buildParams(period, idEntidad), signal });
  },

  getRiesgoFinanciero(period, signal, idEntidad) {
    return get('/enreach/reporte/3-riesgo-financiero', { params: buildParams(period, idEntidad), signal });
  },

  getDemandaHoraria(period, signal, idEntidad) {
    return get('/enreach/reporte/4-demanda-horaria', { params: buildParams(period, idEntidad), signal });
  },

  getCalidadLlamadas(period, signal, idEntidad) {
    return get('/enreach/reporte/5-calidad-llamadas', { params: buildParams(period, idEntidad), signal });
  },

  getSaludMensajeria(period, signal, idEntidad) {
    return get('/enreach/reporte/6-salud-mensajeria', { params: buildParams(period, idEntidad), signal });
  },

  // Tendencia (2 params)
  getTendenciaFacturacion(period, signal, idEntidad) {
    return get('/enreach/reporte/tendencia-facturacion', {
      params: { anio: period?.anio ?? 2023, idEntidad },
      signal,
    });
  },

  // Revenue por país (2 params)
  getRevenuePorPais(period, signal, idEntidad) {
    return get('/enreach/reporte/revenue-por-pais', {
      params: { anio: period?.anio ?? 2023, idEntidad },
      signal,
    });
  },

  // Detalle granular
  getScorecard(period, signal, idEntidad) {
    return get('/enreach/reporte/8-scorecard', { params: buildParams(period, idEntidad), signal });
  },

  getVencimientosAcuerdos(period, signal, idEntidad) {
    return get('/enreach/reporte/vencimientos-acuerdos', {
      params: { idEntidad },
      signal,
    });
  },

  getHealth(signal) {
    return get('/enreach/health', { signal });
  },
};

export default enreachApi;
