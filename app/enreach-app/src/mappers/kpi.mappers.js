import { KPI_CONFIG } from '@/constants/kpis';
import {
  getMoraLevel,
  normalizeNumber,
  pickFirstDefined,
} from '@/mappers/common.mappers';

function resolveKpiValue(source, candidateKeys) {
  return pickFirstDefined(source, candidateKeys, 0);
}

function mapConfigItem(source, configItem, aliases = {}) {
  const candidateKeys = [configItem.key, ...(aliases[configItem.key] || [])];
  const value = resolveKpiValue(source, candidateKeys);

  let status = 'neutral';
  if (configItem.status === 'mora') {
    status = getMoraLevel(value);
  } else if (configItem.status === 'sla') {
    const numericValue = normalizeNumber(value);
    status = numericValue === 0 ? 'ok' : numericValue <= 2 ? 'warning' : 'critical';
  }

  return {
    id: configItem.key,
    label: configItem.label,
    value,
    format: configItem.format,
    status,
  };
}

const enreachAliases = {
  saldoPendiente: ['saldoPendienteTotal'],
  tasaEntrega: ['tasaEntregaMensajes'],
};

const partnerAliases = {
  facturacionPeriodo: ['totalFacturado', 'facturadoPeriodo'],
  cobroPeriodo: ['totalCobrado', 'cobradoPeriodo'],
  carteraVencida: ['saldoPendiente', 'montoVencido'],
  usoPromedioPlan: ['usoPromedioPorcentaje', 'usoPromedio', 'usopromedioporcentaje'],
  tasaEntrega: ['tasaEntregaMensajes', 'tasaEntrega'],
};

const clienteAliases = {
  gastoPeriodo: ['totalGasto', 'gastoTotal', 'gasto'],
  montoPagado: ['totalPagado', 'pagado'],
  usoMinutos: ['totalMinutos', 'minutosConsumidos', 'minutosUso'],
  usoMensajes: ['totalMensajes', 'mensajesConsumidos', 'mensajesUso'],
  colasFueraSla: ['colasFueraSLA', 'colasSla', 'colasAlerta'],
};

export function mapEnreachKpis(dto) {
  return KPI_CONFIG.enreach.map((item) => mapConfigItem(dto, item, enreachAliases));
}

export function mapPartnerKpis(dto) {
  return KPI_CONFIG.partner.map((item) => mapConfigItem(dto, item, partnerAliases));
}

export function mapClienteKpis(dto) {
  return KPI_CONFIG.cliente.map((item) => mapConfigItem(dto, item, clienteAliases));
}
