import { formatCurrencyCompact } from '@/utils/formatters';

function WaterfallChart({ steps = [], height = 260 }) {
  if (!steps.length) return null;

  // Build cumulative positions for each bar.
  // 'total' bars go from 0 to their value (absolute reference).
  // 'increase' bars stack upward from the running total.
  // 'decrease' bars stack downward from the running total.
  const bars = [];
  let running = 0;

  steps.forEach((step) => {
    if (step.type === 'total') {
      // Total bar: absolute from 0 to value
      bars.push({ ...step, bottom: 0, top: step.value });
      running = step.value;
    } else if (step.type === 'decrease') {
      // Decrease: from running total down by the absolute value
      const amount = Math.abs(step.value);
      const top = running;
      const bottom = running - amount;
      bars.push({ ...step, bottom, top, displayValue: -amount });
      running = bottom;
    } else {
      // Increase: from running total up by the value
      const bottom = running;
      const top = running + step.value;
      bars.push({ ...step, bottom, top, displayValue: step.value });
      running = top;
    }
  });

  const allValues = bars.flatMap((b) => [b.bottom, b.top]);
  const maxValue = Math.max(...allValues, 0);
  const minValue = Math.min(...allValues, 0);
  const domain = maxValue - minValue || 1;

  const width = 720;
  const leftMargin = 72;
  const rightMargin = 12;
  const chartWidth = width - leftMargin - rightMargin;
  const innerHeight = 160;
  const chartTop = 24;
  const chartBottom = chartTop + innerHeight;
  const stepWidth = chartWidth / bars.length;

  const yScale = (value) => chartBottom - ((value - minValue) / domain) * innerHeight;

  const fillForType = (type) => {
    if (type === 'decrease') return 'var(--color-status-critical)';
    if (type === 'total') return 'var(--color-chart-secondary)';
    return 'var(--color-chart-primary)';
  };

  return (
    <svg viewBox={`0 0 ${width} ${height}`} style={{ width: '100%', height }} role="img" aria-label="Waterfall monetización">
      {/* Grid lines */}
      {[0, 0.25, 0.5, 0.75, 1].map((ratio) => {
        const value = minValue + domain * ratio;
        const y = yScale(value);
        return (
          <g key={ratio}>
            <line x1={leftMargin} y1={y} x2={width - rightMargin} y2={y} stroke="var(--color-chart-grid)" strokeDasharray="4 4" />
            <text x={leftMargin - 8} y={y + 4} fill="var(--color-text-muted)" fontSize="11" textAnchor="end">
              {formatCurrencyCompact(value)}
            </text>
          </g>
        );
      })}

      {/* Bars */}
      {bars.map((bar, index) => {
        const x = leftMargin + index * stepWidth + 14;
        const barWidth = stepWidth - 24;
        const yTop = yScale(Math.max(bar.top, bar.bottom));
        const yBot = yScale(Math.min(bar.top, bar.bottom));
        const rectHeight = Math.max(12, yBot - yTop);
        const fill = fillForType(bar.type);

        const displayVal = bar.type === 'total' ? bar.top : (bar.displayValue ?? bar.value);

        return (
          <g key={bar.label}>
            <rect x={x} y={yTop} width={barWidth} height={rectHeight} rx="10" fill={fill} opacity={bar.type === 'total' ? 0.9 : 1} />

            {/* Label below */}
            <text x={x + barWidth / 2} y={chartBottom + 24} textAnchor="middle" fill="var(--color-text-body)" fontSize="11">
              {bar.label}
            </text>

            {/* Value above */}
            <text x={x + barWidth / 2} y={yTop - 8} textAnchor="middle" fill="var(--color-text-heading)" fontSize="11" fontWeight="600">
              {formatCurrencyCompact(displayVal)}
            </text>

            {/* Connector line to next bar */}
            {index < bars.length - 1 && bar.type !== 'total' ? (
              <line
                x1={x + barWidth}
                y1={yScale(bar.type === 'decrease' ? bar.bottom : bar.top)}
                x2={leftMargin + (index + 1) * stepWidth + 14}
                y2={yScale(bar.type === 'decrease' ? bar.bottom : bar.top)}
                stroke="var(--color-chart-grid)"
                strokeDasharray="4 4"
              />
            ) : null}

            {/* Connector from total bars */}
            {index < bars.length - 1 && bar.type === 'total' ? (
              <line
                x1={x + barWidth}
                y1={yScale(bar.top)}
                x2={leftMargin + (index + 1) * stepWidth + 14}
                y2={yScale(bar.top)}
                stroke="var(--color-chart-grid)"
                strokeDasharray="4 4"
              />
            ) : null}
          </g>
        );
      })}
    </svg>
  );
}

export default WaterfallChart;
