import { ArrowDownRight, ArrowUpRight, Minus } from 'lucide-react';
import AlertBanner from '@/components/status/AlertBanner';
import { formatCompactNumber, formatCurrencyCompact, formatPercent } from '@/utils/formatters';
import styles from './KpiCard.module.css';

function resolveTrendIcon(variation = 0) {
  if (variation > 0) return ArrowUpRight;
  if (variation < 0) return ArrowDownRight;
  return Minus;
}

function formatDisplayValue(value, format) {
  if (value === null || value === undefined || value === '') return '—';
  if (!format) return value;

  switch (format) {
    case 'currencyCompact':
      return formatCurrencyCompact(value);
    case 'percent':
      return formatPercent(value);
    case 'integer':
      return formatCompactNumber(value, 'es-EC', { maximumFractionDigits: 0 });
    case 'compactNumber':
      return formatCompactNumber(value);
    default:
      return value;
  }
}

function KpiCard({
  label,
  value,
  format,
  support,
  variation,
  variationLabel,
  progress,
  alert,
  icon: Icon,
}) {
  const TrendIcon = resolveTrendIcon(variation);
  const hasVariation = Number.isFinite(Number(variation));
  const displayValue = formatDisplayValue(value, format);

  return (
    <article className={styles.card}>
      <div className={styles.head}>
        <p className={styles.label}>{label}</p>
        {Icon ? <Icon size={18} strokeWidth={1.9} className={styles.icon} aria-hidden="true" /> : null}
      </div>

      <p className={styles.value}>{displayValue}</p>

      {support ? <p className={styles.support}>{support}</p> : null}

      {typeof progress === 'number' ? (
        <div className={styles.progressBlock}>
          <div className={styles.progressTrack}>
            <div className={styles.progressFill} style={{ width: `${Math.max(0, Math.min(progress, 100))}%` }} />
          </div>
          <span className={styles.progressLabel}>{Math.round(progress)}% consumido</span>
        </div>
      ) : null}

      {hasVariation ? (
        <div className={styles.variation}>
          <TrendIcon size={14} strokeWidth={2} aria-hidden="true" />
          <span>{variationLabel ?? `${variation > 0 ? '+' : ''}${variation}%`}</span>
        </div>
      ) : null}

      {alert ? <AlertBanner message={alert} compact variant="warning" /> : null}
    </article>
  );
}

export default KpiCard;
