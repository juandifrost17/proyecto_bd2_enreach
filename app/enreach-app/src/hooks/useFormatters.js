import { useMemo } from 'react';
import {
  formatCompactNumber,
  formatCurrency,
  formatCurrencyCompact,
  formatDuration,
  formatInteger,
  formatPercent,
  formatVariation,
} from '@/utils/formatters';

export default function useFormatters(locale = 'es-EC') {
  return useMemo(() => ({
    currency: (value, options = {}) => formatCurrency(value, locale, options),
    currencyCompact: (value, options = {}) => formatCurrencyCompact(value, locale, options),
    percent: (value, options = {}) => formatPercent(value, locale, options),
    integer: (value, options = {}) => formatInteger(value, locale, options),
    compactNumber: (value, options = {}) => formatCompactNumber(value, locale, options),
    duration: (value, options = {}) => formatDuration(value, locale, options),
    variation: (value, options = {}) => formatVariation(value, locale, options),
  }), [locale]);
}
