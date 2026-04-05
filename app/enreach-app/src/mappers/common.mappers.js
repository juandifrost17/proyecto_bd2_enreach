function resolveFilter(filters = {}, primaryKey, aliasKey) {
  return Boolean(filters[primaryKey] ?? filters[aliasKey]);
}

export function pickFirstDefined(source, keys = [], fallback = null) {
  for (const key of keys) {
    const value = source?.[key];
    if (value !== undefined && value !== null && value !== '') {
      return value;
    }
  }

  return fallback;
}

export function normalizeNumber(value, fallback = 0) {
  const numericValue = Number(value);
  return Number.isFinite(numericValue) ? numericValue : fallback;
}

export function normalizeText(value, fallback = '—') {
  if (value === null || value === undefined || value === '') {
    return fallback;
  }

  return String(value).trim();
}

export function getMoraLevel(days) {
  const value = normalizeNumber(days);
  if (value <= 0) return 'ok';
  if (value <= 30) return 'warning';
  return 'critical';
}

export function getSlaLevel(value) {
  if (typeof value === 'boolean') {
    return value ? 'ok' : 'critical';
  }

  const numericValue = normalizeNumber(value);
  if (numericValue >= 95) return 'ok';
  if (numericValue >= 85) return 'warning';
  return 'critical';
}

export function getRiskLevel(value) {
  const rawValue = normalizeText(value, '').toUpperCase();
  if (rawValue.includes('ALTO') || rawValue.includes('HIGH') || rawValue.includes('CRITICAL')) return 'critical';
  if (rawValue.includes('MEDIO') || rawValue.includes('MEDIUM') || rawValue.includes('WARNING')) return 'warning';
  if (rawValue.includes('BAJO') || rawValue.includes('LOW') || rawValue.includes('OK')) return 'ok';
  return 'neutral';
}

export function groupBy(items = [], getKey = (item) => item) {
  return items.reduce((accumulator, item) => {
    const key = getKey(item);
    if (!accumulator[key]) {
      accumulator[key] = [];
    }
    accumulator[key].push(item);
    return accumulator;
  }, {});
}

export function applyQuickFilters(rows = [], quickFilters = {}) {
  return rows.filter((row) => {
    if (resolveFilter(quickFilters, 'criticalOnly', 'critical') && !(row.criticality === 'critical' || row.riskLevel === 'critical')) {
      return false;
    }

    if (resolveFilter(quickFilters, 'moraOnly', 'mora') && normalizeNumber(row.diasMora) <= 0) {
      return false;
    }

    if (resolveFilter(quickFilters, 'slaOnly', 'sla')) {
      const outOfSla = row.slaStatus === 'critical' || row.cumpleSla === false || row.fueraSla === true;
      if (!outOfSla) {
        return false;
      }
    }

    return true;
  });
}
