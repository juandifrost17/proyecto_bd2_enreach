function toNumber(value) {
  const numericValue = Number(value);
  return Number.isFinite(numericValue) ? numericValue : 0;
}

export function formatCurrency(value, locale = 'es-EC', options = {}) {
  const formatter = new Intl.NumberFormat(locale, {
    style: 'currency',
    currency: options.currency || 'USD',
    maximumFractionDigits: options.maximumFractionDigits ?? 2,
    minimumFractionDigits: options.minimumFractionDigits ?? 0,
  });

  return formatter.format(toNumber(value));
}

export function formatCurrencyCompact(value, locale = 'es-EC', options = {}) {
  const formatter = new Intl.NumberFormat(locale, {
    style: 'currency',
    currency: options.currency || 'USD',
    notation: 'compact',
    maximumFractionDigits: options.maximumFractionDigits ?? 1,
  });

  return formatter.format(toNumber(value));
}

export function formatPercent(value, locale = 'es-EC', options = {}) {
  const rawValue = toNumber(value);
  const normalizedValue = options.alreadyNormalized ? rawValue : rawValue / 100;
  const formatter = new Intl.NumberFormat(locale, {
    style: 'percent',
    maximumFractionDigits: options.maximumFractionDigits ?? 1,
    minimumFractionDigits: options.minimumFractionDigits ?? 0,
  });

  return formatter.format(normalizedValue);
}

export function formatInteger(value, locale = 'es-EC', options = {}) {
  const formatter = new Intl.NumberFormat(locale, {
    maximumFractionDigits: options.maximumFractionDigits ?? 0,
  });
  return formatter.format(toNumber(value));
}

export function formatCompactNumber(value, locale = 'es-EC', options = {}) {
  const formatter = new Intl.NumberFormat(locale, {
    notation: 'compact',
    maximumFractionDigits: options.maximumFractionDigits ?? 1,
  });
  return formatter.format(toNumber(value));
}

export function formatDuration(value, locale = 'es-EC', options = {}) {
  const totalSeconds = Math.max(0, Math.round(toNumber(value)));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;

  if (options.compact === false) {
    return new Intl.ListFormat(locale, { style: 'narrow', type: 'unit' }).format([
      `${minutes} min`,
      `${seconds} s`,
    ]);
  }

  return `${minutes}m ${String(seconds).padStart(2, '0')}s`;
}

export function formatVariation(value, locale = 'es-EC', options = {}) {
  const numericValue = toNumber(value);
  const sign = numericValue > 0 ? '+' : '';
  return `${sign}${formatPercent(numericValue, locale, { ...options, alreadyNormalized: false })}`;
}
