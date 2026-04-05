import { formatCompactNumber, formatPercent } from '@/utils/formatters';

function formatValue(value, unit) {
  if (unit === 'percent') return formatPercent(value);
  return formatCompactNumber(value);
}

// pct is 0–100 scale (e.g. 72 = 72%)
function getStatusColor(pct) {
  if (pct >= 90) return 'var(--color-status-critical)';
  if (pct >= 70) return 'var(--color-status-warning)';
  return 'var(--color-chart-primary)';
}

function BulletChart({
  actual = 0,
  target = 0,
  label = 'Uso',
  unit = 'number',
  thresholdLabel,
  height = 96,
  showPercent = false,
}) {
  const safeTarget = target || 1;

  // pct in 0-100 scale: (55.6 / 3000) * 100 = 1.853
  const pct = (actual / safeTarget) * 100;
  // Cap at 100 for the bar only
  const pctCapped = Math.min(pct, 100);
  const statusColor = getStatusColor(pctCapped);

  const width = 720;
  const labelAreaWidth = 220;
  const chartEndPadding = 20;
  const trackWidth = width - labelAreaWidth - chartEndPadding;
  const barX = labelAreaWidth;
  // Bar width uses fraction (pctCapped/100)
  const actualWidth = (pctCapped / 100) * trackWidth;
  const targetX = barX + trackWidth;

  // formatPercent expects a 0-100 value: internally divides by 100 then Intl ×100
  // formatPercent(1.853) → 1.853/100=0.01853 → Intl: 0.01853 × 100 = 1.853% → "1,9%"
  const mainMetric = showPercent
    ? formatPercent(pct)
    : formatValue(actual, unit);

  const detailText = showPercent
    ? `${formatValue(actual, unit)} de ${formatCompactNumber(target)}`
    : null;

  const subLabel = thresholdLabel || `Objetivo ${formatValue(target, unit)}`;
  const barColor = showPercent ? statusColor : 'var(--color-chart-primary)';
  const metricColor = showPercent ? statusColor : 'var(--color-text-heading)';

  return (
    <svg viewBox={`0 0 ${width} ${height}`} style={{ width: '100%', height }} role="img" aria-label={label}>
      <text x="0" y="22" fill="var(--color-text-heading)" fontSize="13" fontWeight="600">{label}</text>
      <text x="0" y="40" fill="var(--color-text-muted)" fontSize="11">{subLabel}</text>

      <rect x={barX} y="20" width={trackWidth} height="16" rx="8" fill="rgba(70,100,99,0.14)" />
      <rect x={barX} y="20" width={actualWidth} height="16" rx="8" fill={barColor} />
      <line x1={targetX} y1="14" x2={targetX} y2="42"
        stroke="var(--color-chart-secondary)" strokeWidth="4" strokeLinecap="round" />

      <text
        x={barX + Math.max(actualWidth + 8, 16)}
        y="62"
        fill={metricColor}
        fontSize={showPercent ? "14" : "12"}
        fontWeight={showPercent ? "700" : "600"}
      >
        {mainMetric}
      </text>

      {detailText && (
        <text
          x={barX + Math.max(actualWidth + 8, 16)}
          y="78"
          fill="var(--color-text-muted)"
          fontSize="10"
        >
          {detailText}
        </text>
      )}
    </svg>
  );
}

export default BulletChart;
