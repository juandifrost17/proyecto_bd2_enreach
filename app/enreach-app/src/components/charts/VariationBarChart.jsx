import { Bar, BarChart, CartesianGrid, Cell, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { formatCompactNumber, formatPercent } from '@/utils/formatters';

function VariationBarChart({ data = [], valueKey = 'value', variationKey = 'variation', labelKey = 'label', height = 284 }) {
  return (
    <div style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <BarChart data={data} layout="vertical" margin={{ top: 8, right: 12, bottom: 0, left: 0 }}>
          <CartesianGrid horizontal={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
          <XAxis type="number" tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} tickLine={false} axisLine={false} tickFormatter={(value) => formatCompactNumber(value)} />
          <YAxis type="category" dataKey={labelKey} width={110} tick={{ fill: 'var(--color-text-body)', fontSize: 12 }} tickLine={false} axisLine={false} />
          <Tooltip
            formatter={(value, name, payload) => {
              if (name === valueKey) return [formatCompactNumber(value), 'Volumen'];
              return [formatPercent(payload?.payload?.[variationKey]), 'Variación'];
            }}
            contentStyle={{ border: 'none', borderRadius: 12, boxShadow: 'var(--shadow-float)' }}
          />
          <Bar dataKey={valueKey} radius={[8, 8, 8, 8]}>
            {data.map((entry) => (
              <Cell key={entry[labelKey]} fill={entry[variationKey] > 0 ? 'var(--color-status-critical)' : 'var(--color-chart-primary)'} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

export default VariationBarChart;
