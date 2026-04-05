const env = typeof import.meta !== 'undefined' ? import.meta.env : undefined;

export const API_BASE_URL = env?.VITE_API_BASE_URL ?? 'http://localhost:8080/api/dashboard';

export const HTTP_STATUS = Object.freeze({
  OK: 200,
  NO_CONTENT: 204,
});

export const DEFAULT_PERIOD = Object.freeze({
  anio: 2023,
  periodo: 1,
  tipoFiltro: 'T',
});

export const PERIOD_FILTER_TYPES = Object.freeze({
  QUARTER: 'T',
  YEAR: 'A',
});

export const DATA_YEARS = Object.freeze([2025, 2024, 2023]);
