import {
  CartesianGrid, Line, LineChart, ReferenceLine,
  ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { formatCompactNumber } from '@/utils/formatters';

// Colors that share the green/teal family but are clearly distinguishable
const YEAR_BAND_COLORS = ['rgba(0,101,101,0.04)', 'rgba(0,77,77,0.03)'];

// Tick renderer: shows only the month abbreviation (first word of "Ene 2023")
// For January ticks, shows the year below in bold
function YearAwareTick({ x, y, payload, data }) {
  const fullLabel = payload.value;           // e.g. "Ene 2023"
  const [monthAbbr, year] = fullLabel.split(' ');
  // A point is a January tick if its label starts with 'Ene'
  const isJan = monthAbbr === 'Ene';

  return (
    <g transform={`translate(${x},${y})`}>
      <text x={0} y={0} dy={12} textAnchor="middle"
        fill="var(--color-text-muted)" fontSize={10}
        fontWeight={isJan ? 600 : 400}>
        {monthAbbr}
      </text>
      {isJan && year && (
        <text x={0} y={0} dy={24} textAnchor="middle"
          fill="var(--color-text-heading)" fontSize={10} fontWeight={700}>
          {year}
        </text>
      )}
    </g>
  );
}

function CustomLegend({ lines }) {
  return (
    <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', justifyContent: 'flex-end', marginBottom: 8 }}>
      {lines.map((line) => (
        <div key={line.dataKey} style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
          <svg width={22} height={10}>
            <line x1={0} y1={5} x2={22} y2={5}
              stroke={line.color} strokeWidth={2}
              strokeDasharray={line.dashed ? '5 3' : undefined} />
          </svg>
          <span style={{ fontSize: '0.75rem', color: 'var(--color-text-body)' }}>
            {line.displayLabel || line.label}
          </span>
        </div>
      ))}
    </div>
  );
}

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  // Only show series with non-zero values
  const visible = payload.filter((p) => p.value > 0);
  return (
    <div style={{
      background: 'var(--color-surface-lowest)', border: 'none',
      borderRadius: 12, boxShadow: 'var(--shadow-float)',
      padding: '0.55rem 0.85rem', fontSize: '0.8rem', minWidth: 140,
    }}>
      <p style={{ fontWeight: 600, marginBottom: 6, color: 'var(--color-text-heading)' }}>{label}</p>
      {visible.length === 0 && (
        <p style={{ color: 'var(--color-text-muted)', fontStyle: 'italic' }}>Sin actividad</p>
      )}
      {visible.map((p) => (
        <p key={p.dataKey} style={{ color: p.stroke, marginBottom: 2 }}>
          {p.name}: <strong>{formatCompactNumber(p.value)}</strong>
        </p>
      ))}
    </div>
  );
}

function MultiLineChart({
  data = [],
  xKey = 'label',          // default changed: must be the unique full label "Ene 2023"
  lines = [],
  height = 300,
  groupByYear = false,
}) {
  // Year separator reference lines: at every point where mes === 1 AND idx > 0
  const yearRefLines = groupByYear
    ? data.reduce((acc, point, idx) => {
        if (idx > 0 && point.mes === 1 && point.anio) {
          acc.push({ x: point[xKey], anio: point.anio });
        }
        return acc;
      }, [])
    : [];

  return (
    <div style={{ width: '100%' }}>
      <CustomLegend lines={lines} />
      <div style={{ width: '100%', height }}>
        <ResponsiveContainer>
          <LineChart data={data} margin={{ top: 4, right: 16, bottom: groupByYear ? 24 : 8, left: 0 }}>
            <CartesianGrid stroke="var(--color-chart-grid)" strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey={xKey}
              tickLine={false}
              axisLine={false}
              interval="preserveStartEnd"
              height={groupByYear ? 38 : 22}
              tick={
                groupByYear
                  ? (props) => <YearAwareTick {...props} data={data} />
                  : { fill: 'var(--color-text-muted)', fontSize: 10 }
              }
            />
            <YAxis
              tickLine={false}
              axisLine={false}
              tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
              tickFormatter={(v) => formatCompactNumber(v)}
              width={36}
            />
            <Tooltip content={<CustomTooltip />} />

            {/* Vertical year-separator lines */}
            {yearRefLines.map(({ x, anio }) => (
              <ReferenceLine
                key={`yr-${anio}`}
                x={x}
                stroke="var(--color-chart-grid)"
                strokeWidth={1.5}
                strokeDasharray="4 3"
              />
            ))}

            {lines.map((line, idx) => (
              <Line
                key={line.dataKey}
                type="monotone"
                dataKey={line.dataKey}
                name={line.label}
                stroke={line.color}
                strokeWidth={line.strokeWidth || 2}
                strokeDasharray={line.dashed ? '6 4' : undefined}
                dot={false}
                activeDot={{ r: 4, strokeWidth: 0 }}
                connectNulls={false}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
      {groupByYear && (
        <p style={{ fontSize: '0.68rem', color: 'var(--color-text-muted)', textAlign: 'center', marginTop: 4 }}>
          Las líneas verticales punteadas marcan el cambio de año
        </p>
      )}
    </div>
  );
}

export default MultiLineChart;
