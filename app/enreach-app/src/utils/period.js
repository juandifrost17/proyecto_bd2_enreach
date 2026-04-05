import { DEFAULT_PERIOD, PERIOD_FILTER_TYPES } from '@/constants/api';

export function getCurrentQuarter(monthNumber) {
  return Math.ceil((Number(monthNumber) || 1) / 3);
}

export function getMaxPeriodForFilter(tipoFiltro) {
  switch (tipoFiltro) {
    case PERIOD_FILTER_TYPES.QUARTER:
      return 4;
    case PERIOD_FILTER_TYPES.YEAR:
      return 1;
    default:
      return DEFAULT_PERIOD.periodo;
  }
}

export function clampPeriodValue(periodo, tipoFiltro) {
  const maxPeriod = getMaxPeriodForFilter(tipoFiltro);
  const numericValue = Number(periodo);
  if (!Number.isFinite(numericValue)) return DEFAULT_PERIOD.periodo;
  return Math.min(Math.max(Math.trunc(numericValue), 1), maxPeriod);
}

export function normalizePeriodInput(period = {}) {
  const rawType = String(period.tipoFiltro ?? DEFAULT_PERIOD.tipoFiltro).toUpperCase();
  const tipoFiltro = Object.values(PERIOD_FILTER_TYPES).includes(rawType)
    ? rawType
    : DEFAULT_PERIOD.tipoFiltro;

  const anio = Number.isFinite(Number(period.anio))
    ? Math.trunc(Number(period.anio))
    : DEFAULT_PERIOD.anio;

  const periodo = tipoFiltro === PERIOD_FILTER_TYPES.YEAR
    ? 1
    : clampPeriodValue(period.periodo ?? DEFAULT_PERIOD.periodo, tipoFiltro);

  return { anio, periodo, tipoFiltro };
}

function getPeriodLabel(tipoFiltro, periodo, anio) {
  if (tipoFiltro === PERIOD_FILTER_TYPES.QUARTER) {
    return `Trimestre ${periodo}`;
  }
  return `Año ${anio}`;
}

function getPeriodOptions(tipoFiltro, maxPeriod) {
  if (tipoFiltro === PERIOD_FILTER_TYPES.QUARTER) {
    return Array.from({ length: maxPeriod }, (_, index) => ({
      value: index + 1,
      label: `Trimestre ${index + 1}`,
    }));
  }
  return [{ value: 1, label: 'Año completo' }];
}

export function buildPeriodMeta(period) {
  const normalized = normalizePeriodInput(period);
  const maxPeriod = getMaxPeriodForFilter(normalized.tipoFiltro);
  const periodLabel = getPeriodLabel(normalized.tipoFiltro, normalized.periodo, normalized.anio);
  return {
    ...normalized,
    maxPeriod,
    periodLabel,
    periodOptions: getPeriodOptions(normalized.tipoFiltro, maxPeriod),
  };
}
