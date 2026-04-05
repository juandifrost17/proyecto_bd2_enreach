import { useMemo } from 'react';
import {
  Bar, BarChart, CartesianGrid, Legend,
  ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { formatCompactNumber } from '@/utils/formatters';

const MONTH_ORDER = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

const SERIES = [
  { key: 'llamadas', label: 'Llamadas', color: '#006565',  unit: 'llamadas' },
  { key: 'mensajes', label: 'Mensajes', color: '#4a7c59',  unit: 'mensajes' },
  { key: 'minutos',  label: 'Minutos',  color: '#80cbc4',  unit: 'min'      },
];

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  const nonZero = payload.filter((p) => p.value > 0);
  return (
    <div style={{
      background: 'var(--color-surface-lowest)', border: 'none',
      borderRadius: 12, boxShadow: 'var(--shadow-float)',
      padding: '0.6rem 0.9rem', fontSize: '0.8rem', minWidth: 140,
    }}>
      <p style={{ fontWeight: 600, marginBottom: 6, color: 'var(--color-text-heading)' }}>{label}</p>
      {nonZero.length === 0 && (
        <p style={{ color: 'var(--color-text-muted)', fontStyle: 'italic' }}>Sin actividad</p>
      )}
      {nonZero.map((p) => {
        const series = SERIES.find((s) => s.key === p.dataKey);
        return (
          <p key={p.dataKey} style={{ color: p.fill, marginBottom: 2 }}>
            {p.name}: <strong>{formatCompactNumber(p.value)}</strong>
            {series ? ` ${series.unit}` : ''}
          </p>
        );
      })}
    </div>
  );
}

// selectedYear comes from period.anio — no internal selector
function YearBarChart({ data = [], selectedYear, height = 300 }) {
  const chartData = useMemo(() => {
    const byMonth = new Map(
      data
        .filter((d) => d.anio === selectedYear)
        .map((d) => [d.mes, d]),
    );
    return MONTH_ORDER.map((abbr, idx) => {
      const mes = idx + 1;
      const point = byMonth.get(mes);
      return {
        label: abbr,
        llamadas: point?.llamadas ?? 0,
        mensajes: point?.mensajes ?? 0,
        minutos:  point?.minutos  ?? 0,
      };
    });
  }, [data, selectedYear]);

  if (!data.length) return (
    <p style={{ textAlign: 'center', color: 'var(--color-text-muted)', padding: '2rem 0', fontSize: '0.85rem' }}>
      Sin datos disponibles
    </p>
  );

  return (
    <div style={{ width: '100%' }}>
      <div style={{ width: '100%', height }}>
        <ResponsiveContainer>
          <BarChart data={chartData} margin={{ top: 4, right: 8, bottom: 4, left: 0 }} barCategoryGap="28%">
            <CartesianGrid vertical={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
            <XAxis dataKey="label" tickLine={false} axisLine={false}
              tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} />
            <YAxis tickLine={false} axisLine={false}
              tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
              tickFormatter={(v) => formatCompactNumber(v)} width={36} />
            <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(0,101,101,0.04)' }} />
            <Legend verticalAlign="top" align="right" iconType="square" iconSize={10}
              wrapperStyle={{ fontSize: '0.78rem', paddingBottom: 8 }} />
            {SERIES.map((s) => (
              <Bar key={s.key} dataKey={s.key} name={s.label} stackId="stack"
                fill={s.color} radius={s.key === 'minutos' ? [4, 4, 0, 0] : 0} maxBarSize={40} />
            ))}
          </BarChart>
        </ResponsiveContainer>
      </div>
      <p style={{ fontSize: '0.68rem', color: 'var(--color-text-muted)', textAlign: 'center', marginTop: 4 }}>
        Llamadas y Mensajes en cantidad de eventos · Minutos en duración total
      </p>
    </div>
  );
}

export default YearBarChart;
