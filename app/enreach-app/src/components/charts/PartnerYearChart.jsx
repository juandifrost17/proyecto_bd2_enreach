import { useMemo } from 'react';
import {
  Bar, BarChart, CartesianGrid, Cell,
  ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { formatCurrencyCompact, formatCurrency } from '@/utils/formatters';

const PARTNER_COLORS = [
  '#006565', '#4a7c59', '#00838f', '#37474f', '#2e7d32',
  '#00695c', '#546e7a', '#558b2f', '#78909c', '#26a69a',
];

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  const val = payload[0]?.value ?? 0;
  return (
    <div style={{
      background: 'var(--color-surface-lowest)', border: 'none',
      borderRadius: 12, boxShadow: 'var(--shadow-float)',
      padding: '0.6rem 0.9rem', fontSize: '0.8rem', minWidth: 160,
    }}>
      <p style={{ fontWeight: 600, marginBottom: 4, color: 'var(--color-text-heading)' }}>{label}</p>
      <p style={{ color: payload[0]?.fill }}><strong>{formatCurrency(val)}</strong></p>
    </div>
  );
}

// selectedYear comes from period.anio — no internal selector
function PartnerYearChart({ data = [], categories = [], selectedYear, height = 340 }) {
  const colorMap = useMemo(() => {
    const map = {};
    categories.forEach((cat, idx) => { map[cat.key] = PARTNER_COLORS[idx % PARTNER_COLORS.length]; });
    return map;
  }, [categories]);

  const chartData = useMemo(() => {
    const yearRow = data.find((d) => Number(d.label) === Number(selectedYear)) ?? {};
    return categories
      .map((cat) => ({
        label: cat.label,
        value: yearRow[cat.key] ?? 0,
        color: colorMap[cat.key],
      }))
      .sort((a, b) => b.value - a.value);
  }, [data, categories, selectedYear, colorMap]);

  if (!data.length) return (
    <p style={{ textAlign: 'center', color: 'var(--color-text-muted)', padding: '2rem 0' }}>
      Sin datos disponibles
    </p>
  );

  return (
    <div style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <BarChart
          data={chartData}
          margin={{ top: 8, right: 12, bottom: 64, left: 8 }}
          barCategoryGap="28%"
        >
          <CartesianGrid vertical={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
          <XAxis
            dataKey="label"
            tickLine={false}
            axisLine={false}
            tick={{ fill: 'var(--color-text-body)', fontSize: 11 }}
            interval={0}
            angle={-35}
            textAnchor="end"
            height={70}
          />
          <YAxis
            tickLine={false}
            axisLine={false}
            tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
            tickFormatter={(v) => formatCurrencyCompact(v)}
            width={56}
          />
          <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(0,101,101,0.04)' }} />
          <Bar dataKey="value" name="Facturado" radius={[6, 6, 0, 0]} maxBarSize={48}>
            {chartData.map((entry, idx) => (
              <Cell key={`cell-${idx}`} fill={entry.color} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

export default PartnerYearChart;
