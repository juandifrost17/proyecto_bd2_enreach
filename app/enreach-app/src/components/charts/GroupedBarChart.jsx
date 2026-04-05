import {
  Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { formatCompactNumber, formatCurrencyCompact } from '@/utils/formatters';

const COLORS = [
  'var(--color-chart-primary)',
  'var(--color-chart-secondary)',
  'var(--color-chart-tertiary)',
  'var(--color-status-critical)',
  '#6366f1',
  '#f59e0b',
  '#10b981',
  '#ef4444',
];

function formatValue(value, format) {
  if (format === 'currency') return formatCurrencyCompact(value);
  return formatCompactNumber(value);
}

function GroupedBarChart({
  data = [],
  categories = [],
  labelKey = 'label',
  valueFormat = 'currency',
  height = 320,
}) {
  return (
    <div style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <BarChart data={data} margin={{ top: 8, right: 12, bottom: 4, left: 4 }}>
          <CartesianGrid vertical={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
          <XAxis
            dataKey={labelKey}
            tickLine={false}
            axisLine={false}
            tick={{ fill: 'var(--color-text-body)', fontSize: 12, fontWeight: 600 }}
          />
          <YAxis
            tickLine={false}
            axisLine={false}
            tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
            tickFormatter={(v) => formatValue(v, valueFormat)}
          />
          <Tooltip
            cursor={{ fill: 'rgba(0, 101, 101, 0.05)' }}
            formatter={(value, name) => [formatValue(value, valueFormat), name]}
            contentStyle={{ border: 'none', borderRadius: 12, boxShadow: 'var(--shadow-float)' }}
          />
          <Legend
            verticalAlign="bottom"
            align="center"
            iconType="square"
            iconSize={10}
            wrapperStyle={{ fontSize: '0.75rem', paddingTop: 12 }}
          />
          {categories.map((cat, idx) => (
            <Bar
              key={cat.key}
              dataKey={cat.key}
              name={cat.label}
              fill={cat.color || COLORS[idx % COLORS.length]}
              radius={[4, 4, 0, 0]}
              maxBarSize={28}
            />
          ))}
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

export default GroupedBarChart;
