import { formatPercent } from '@/utils/formatters';

function FunnelChart({ stages = [], height = 266 }) {
  if (!stages.length) return null;

  const width = 620;
  const maxCount = Math.max(...stages.map((stage) => stage.count), 1);
  const stageHeight = 44;
  const gap = 10;

  return (
    <svg viewBox={`0 0 ${width} ${height}`} style={{ width: '100%', height }} role="img" aria-label="Embudo de calidad de voz">
      {stages.map((stage, index) => {
        const ratio = stage.count / maxCount;
        const nextRatio = stages[index + 1] ? stages[index + 1].count / maxCount : ratio * 0.78;
        const topWidth = 440 * ratio + 90;
        const bottomWidth = 440 * nextRatio + 90;
        const y = index * (stageHeight + gap) + 8;
        const xTop = (width - topWidth) / 2;
        const xBottom = (width - bottomWidth) / 2;
        const points = [
          `${xTop},${y}`,
          `${xTop + topWidth},${y}`,
          `${xBottom + bottomWidth},${y + stageHeight}`,
          `${xBottom},${y + stageHeight}`,
        ].join(' ');
        const alpha = 1 - index * 0.12;

        return (
          <g key={stage.label}>
            <polygon points={points} fill={`rgba(0, 101, 101, ${Math.max(0.28, alpha).toFixed(2)})`} />
            <text x={width / 2} y={y + stageHeight / 2 - 2} textAnchor="middle" fill="white" fontSize="13" fontWeight="600">
              {stage.label}
            </text>
            <text x={width / 2} y={y + stageHeight / 2 + 14} textAnchor="middle" fill="white" fontSize="11">
              {stage.count} · {formatPercent(stage.rate)}
            </text>
          </g>
        );
      })}
    </svg>
  );
}

export default FunnelChart;
