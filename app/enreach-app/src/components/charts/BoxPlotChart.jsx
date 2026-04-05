import { formatDuration } from '@/utils/formatters';

function BoxPlotChart({ items = [] }) {
  if (!items.length) return null;

  const width = 720;
  const left = 150;
  const right = 16;
  const top = 8;
  const rowHeight = 44;
  const axisHeight = 28;
  const chartBottom = top + items.length * rowHeight;
  const height = chartBottom + axisHeight;
  const maxValue = Math.max(...items.map((item) => item.max), 1);
  const xScale = (value) => left + ((width - left - right) * value) / maxValue;

  return (
    <svg viewBox={`0 0 ${width} ${height}`} style={{ width: '100%', height }} role="img" aria-label="Box plot de espera">
      {/* Grid lines — from top to chartBottom only */}
      {[0, 0.25, 0.5, 0.75, 1].map((ratio) => {
        const value = maxValue * ratio;
        const x = xScale(value);
        return (
          <g key={ratio}>
            <line x1={x} y1={top} x2={x} y2={chartBottom} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
          </g>
        );
      })}

      {/* Data rows */}
      {items.map((item, index) => {
        const y = top + index * rowHeight + rowHeight / 2;
        return (
          <g key={item.label}>
            <text x={left - 12} y={y + 4} fill="var(--color-text-body)" fontSize="11" textAnchor="end">{item.label}</text>
            {/* Whisker line min→max */}
            <line x1={xScale(item.min)} y1={y} x2={xScale(item.max)} y2={y} stroke="var(--color-chart-primary)" strokeWidth="1.5" />
            {/* Min cap */}
            <line x1={xScale(item.min)} y1={y - 7} x2={xScale(item.min)} y2={y + 7} stroke="var(--color-chart-primary)" strokeWidth="1.5" />
            {/* Max cap */}
            <line x1={xScale(item.max)} y1={y - 7} x2={xScale(item.max)} y2={y + 7} stroke="var(--color-chart-primary)" strokeWidth="1.5" />
            {/* IQR box */}
            <rect
              x={xScale(item.p25)}
              y={y - 12}
              width={Math.max(10, xScale(item.p75) - xScale(item.p25))}
              height="24"
              rx="6"
              fill="rgba(0, 101, 101, 0.14)"
              stroke="var(--color-chart-primary)"
              strokeWidth="1.5"
            />
            {/* Median line */}
            <line x1={xScale(item.median)} y1={y - 12} x2={xScale(item.median)} y2={y + 12} stroke="var(--color-chart-primary)" strokeWidth="2.5" />
          </g>
        );
      })}

      {/* Axis labels — fixed at bottom */}
      {[0, 0.25, 0.5, 0.75, 1].map((ratio) => {
        const value = maxValue * ratio;
        const x = xScale(value);
        return (
          <text key={`label-${ratio}`} x={x} y={chartBottom + 18} textAnchor="middle" fill="var(--color-text-muted)" fontSize="10">
            {formatDuration(value)}
          </text>
        );
      })}
    </svg>
  );
}

export default BoxPlotChart;
