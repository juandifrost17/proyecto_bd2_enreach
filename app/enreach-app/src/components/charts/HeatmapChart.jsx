function HeatmapChart({ matrix = [], xLabels = [], yLabels = [], height = 278 }) {
  const rows = matrix.length;
  const cols = matrix[0]?.length || 0;
  const width = 720;
  const labelCol = 52;
  const topOffset = 26;
  const bottomOffset = 36;
  const cellWidth = cols ? (width - labelCol) / cols : 0;
  const cellHeight = rows ? (height - topOffset - bottomOffset) / rows : 0;
  const flatValues = matrix.flat();
  const maxValue = Math.max(...flatValues, 1);

  const fillForValue = (value) => {
    const ratio = Math.max(0, Math.min(1, value / maxValue));
    const alpha = 0.08 + ratio * 0.86;
    return `rgba(0, 101, 101, ${alpha.toFixed(2)})`;
  };

  return (
    <svg viewBox={`0 0 ${width} ${height}`} style={{ width: '100%', height }} role="img" aria-label="Heatmap de demanda horaria">
      {xLabels.map((label, index) => (
        <text key={label} x={labelCol + index * cellWidth + cellWidth / 2} y="16" textAnchor="middle" fill="var(--color-text-muted)" fontSize="10">
          {label}
        </text>
      ))}

      {yLabels.map((label, rowIndex) => (
        <g key={label}>
          <text x="4" y={topOffset + rowIndex * cellHeight + cellHeight / 2 + 4} fill="var(--color-text-body)" fontSize="11">
            {label}
          </text>
          {matrix[rowIndex].map((value, colIndex) => (
            <rect
              key={`${rowIndex}-${colIndex}`}
              x={labelCol + colIndex * cellWidth + 2}
              y={topOffset + rowIndex * cellHeight + 2}
              width={Math.max(0, cellWidth - 4)}
              height={Math.max(0, cellHeight - 4)}
              rx="7"
              fill={fillForValue(value)}
            />
          ))}
        </g>
      ))}

      {/* Legend — spaced properly */}
      <text x={width - 210} y={height - 8} fill="var(--color-text-muted)" fontSize="10" textAnchor="end">Baja</text>
      <rect x={width - 200} y={height - 18} width="18" height="10" rx="4" fill="rgba(0, 101, 101, 0.12)" />
      <rect x={width - 178} y={height - 18} width="18" height="10" rx="4" fill="rgba(0, 101, 101, 0.35)" />
      <rect x={width - 156} y={height - 18} width="18" height="10" rx="4" fill="rgba(0, 101, 101, 0.6)" />
      <rect x={width - 134} y={height - 18} width="18" height="10" rx="4" fill="rgba(0, 101, 101, 0.85)" />
      <text x={width - 108} y={height - 8} fill="var(--color-text-muted)" fontSize="10">Alta</text>
    </svg>
  );
}

export default HeatmapChart;
