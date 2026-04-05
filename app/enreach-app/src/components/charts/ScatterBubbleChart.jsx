import {
  CartesianGrid,
  ResponsiveContainer,
  Scatter,
  ScatterChart,
  Tooltip,
  XAxis,
  YAxis,
  ZAxis,
} from 'recharts';
import { formatCompactNumber, formatPercent } from '@/utils/formatters';

function ScatterBubbleChart({ data = [], xKey = 'x', yKey = 'y', sizeKey = 'z', labelKey = 'label', height = 292 }) {
  return (
    <div style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <ScatterChart margin={{ top: 12, right: 8, bottom: 8, left: 0 }}>
          <CartesianGrid stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
          <XAxis type="number" dataKey={xKey} name="Actividad" tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} tickLine={false} axisLine={false} tickFormatter={(value) => formatCompactNumber(value)} />
          <YAxis type="number" dataKey={yKey} name="Entrega" tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} tickLine={false} axisLine={false} tickFormatter={(value) => formatPercent(value)} />
          <ZAxis type="number" dataKey={sizeKey} range={[120, 1200]} />
          <Tooltip
            cursor={{ strokeDasharray: '4 4' }}
            formatter={(value, name) => {
              if (name === yKey) return [formatPercent(value), 'Entrega'];
              return [formatCompactNumber(value), name];
            }}
            labelFormatter={(_, payload) => payload?.[0]?.payload?.[labelKey] || ''}
            contentStyle={{ border: 'none', borderRadius: 12, boxShadow: 'var(--shadow-float)' }}
          />
          <Scatter data={data} fill="var(--color-chart-primary)" fillOpacity={0.7} />
        </ScatterChart>
      </ResponsiveContainer>
    </div>
  );
}

export default ScatterBubbleChart;
