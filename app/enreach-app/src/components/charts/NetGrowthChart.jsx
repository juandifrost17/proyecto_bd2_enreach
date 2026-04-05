import {
  Bar, BarChart, CartesianGrid, Cell, LabelList,
  ReferenceLine, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { formatCompactNumber } from '@/utils/formatters';

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  const altas = payload.find((p) => p.dataKey === 'altas')?.value ?? 0;
  const bajas = payload.find((p) => p.dataKey === 'bajas')?.value ?? 0;
  const neto = altas + bajas;

  return (
    <div style={{
      background: 'var(--color-surface-lowest)', border: 'none',
      borderRadius: 12, boxShadow: 'var(--shadow-float)',
      padding: '0.6rem 0.9rem', fontSize: '0.8rem', minWidth: 130,
    }}>
      <p style={{ fontWeight: 600, marginBottom: 6, color: 'var(--color-text-heading)' }}>{label}</p>
      <p style={{ color: 'var(--color-chart-primary)', marginBottom: 2 }}>
        ▲ Altas: <strong>{formatCompactNumber(altas)}</strong>
      </p>
      <p style={{ color: 'var(--color-status-critical)', marginBottom: 2 }}>
        ▼ Bajas: <strong>{formatCompactNumber(Math.abs(bajas))}</strong>
      </p>
      <hr style={{ border: 'none', borderTop: '1px solid var(--color-chart-grid)', margin: '6px 0' }} />
      <p style={{ color: neto >= 0 ? 'var(--color-chart-primary)' : 'var(--color-status-critical)', fontWeight: 700 }}>
        Neto: {neto > 0 ? '+' : ''}{formatCompactNumber(neto)}
      </p>
    </div>
  );
}

function NetGrowthChart({ data = [], height = 280 }) {
  if (!data.length) return null;

  const enriched = data.map((d) => ({
    ...d,
    neto: (d.altas || 0) + (d.bajas || 0),
  }));

  return (
    <div style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <BarChart
          data={enriched}
          margin={{ top: 24, right: 16, bottom: 4, left: 0 }}
          barCategoryGap="38%"
          barGap={3}
        >
          <CartesianGrid vertical={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
          <XAxis
            dataKey="label"
            tickLine={false}
            axisLine={false}
            tick={{ fill: 'var(--color-text-body)', fontSize: 11 }}
          />
          <YAxis
            tickLine={false}
            axisLine={false}
            tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
            tickFormatter={(v) => formatCompactNumber(v)}
            width={32}
          />
          <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(0,101,101,0.04)' }} />
          <ReferenceLine y={0} stroke="var(--color-text-muted)" strokeWidth={1} />

          <Bar dataKey="altas" name="Altas" fill="var(--color-chart-primary)" radius={[4, 4, 0, 0]} maxBarSize={36}>
            <LabelList dataKey="altas" position="top" style={{ fontSize: 10, fill: 'var(--color-text-muted)' }}
              formatter={(v) => (v > 0 ? `+${v}` : '')} />
          </Bar>

          <Bar dataKey="bajas" name="Bajas" radius={[0, 0, 4, 4]} maxBarSize={36}>
            {enriched.map((entry, idx) => (
              <Cell key={idx} fill="var(--color-status-critical)" />
            ))}
            <LabelList dataKey="bajas" position="insideBottom"
              style={{ fontSize: 10, fill: 'white', fontWeight: 600 }}
              formatter={(v) => (v < 0 ? v : '')} />
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

export default NetGrowthChart;
