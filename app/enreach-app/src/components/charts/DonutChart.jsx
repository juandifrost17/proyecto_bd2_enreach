import { formatCompactNumber, formatPercent } from '@/utils/formatters';

function DonutChart({ contestadas = 0, noContestadas = 0, height = 340 }) {
  const total = contestadas + noContestadas;
  if (!total) return null;

  const contestadasPct = (contestadas / total) * 100;
  const noContestadasPct = (noContestadas / total) * 100;

  const width = 620;
  const cx = width / 2;
  const donutCy = 140;
  const outerR = 110;
  const innerR = outerR * 0.58;

  const contestadasAngle = (contestadasPct / 100) * 360;
  const startAngle = -90;

  function polarToCartesian(angleDeg, radius) {
    const rad = (angleDeg * Math.PI) / 180;
    return { x: cx + radius * Math.cos(rad), y: donutCy + radius * Math.sin(rad) };
  }

  function describeArc(startDeg, endDeg, outer, inner) {
    const sweep = endDeg - startDeg;
    const largeArc = sweep > 180 ? 1 : 0;
    const os = polarToCartesian(startDeg, outer);
    const oe = polarToCartesian(endDeg, outer);
    const ie = polarToCartesian(endDeg, inner);
    const is2 = polarToCartesian(startDeg, inner);
    return [
      `M ${os.x} ${os.y}`, `A ${outer} ${outer} 0 ${largeArc} 1 ${oe.x} ${oe.y}`,
      `L ${ie.x} ${ie.y}`, `A ${inner} ${inner} 0 ${largeArc} 0 ${is2.x} ${is2.y}`, 'Z',
    ].join(' ');
  }

  const contestadasEnd = startAngle + contestadasAngle;
  const contestadasPath = contestadasPct >= 100
    ? describeArc(startAngle, startAngle + 359.99, outerR, innerR)
    : describeArc(startAngle, contestadasEnd, outerR, innerR);
  const noContestadasPath = noContestadasPct >= 100
    ? describeArc(startAngle, startAngle + 359.99, outerR, innerR)
    : noContestadasPct > 0 ? describeArc(contestadasEnd, startAngle + 360, outerR, innerR) : '';

  const legendY = donutCy + outerR + 40;

  return (
    <svg viewBox={`0 0 ${width} ${height}`} style={{ width: '100%', height }} role="img" aria-label="Contestadas vs no contestadas">
      {contestadasPct > 0 && <path d={contestadasPath} fill="var(--color-chart-primary)" />}
      {noContestadasPct > 0 && <path d={noContestadasPath} fill="var(--color-status-critical)" />}

      <text x={cx} y={donutCy - 8} textAnchor="middle" fill="var(--color-text-heading)" fontSize="24" fontWeight="600">
        {formatCompactNumber(total)}
      </text>
      <text x={cx} y={donutCy + 16} textAnchor="middle" fill="var(--color-text-muted)" fontSize="12">
        llamadas totales
      </text>

      <g transform={`translate(${cx - 160}, ${legendY})`}>
        <rect x="0" y="-10" width="12" height="12" rx="3" fill="var(--color-chart-primary)" />
        <text x="18" y="1" fill="var(--color-text-body)" fontSize="12" fontWeight="500">
          Contestadas: {formatCompactNumber(contestadas)} ({formatPercent(contestadasPct)})
        </text>
      </g>
      <g transform={`translate(${cx + 30}, ${legendY})`}>
        <rect x="0" y="-10" width="12" height="12" rx="3" fill="var(--color-status-critical)" />
        <text x="18" y="1" fill="var(--color-text-body)" fontSize="12" fontWeight="500">
          No contestadas: {formatCompactNumber(noContestadas)} ({formatPercent(noContestadasPct)})
        </text>
      </g>
    </svg>
  );
}

export default DonutChart;
