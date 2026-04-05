import { useState } from 'react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { formatCompactNumber, formatPercent } from '@/utils/formatters';

const PAGE_SIZE = 6;
const DEFAULT_COLORS = ['var(--color-chart-primary)', 'var(--color-chart-secondary)', 'var(--color-chart-tertiary)', 'var(--color-status-critical)'];

function formatValue(value, valueFormat) {
  if (valueFormat === 'percent') return formatPercent(value);
  if (valueFormat === 'currency') return formatCompactNumber(value);
  return formatCompactNumber(value);
}

const paginatorStyle = {
  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
  gap: '0.75rem', paddingTop: '0.75rem',
};

function navBtnStyle(disabled) {
  return {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
    width: 32, height: 32, border: '1px solid var(--color-chart-grid)', borderRadius: 8,
    background: disabled ? 'var(--color-surface-low)' : 'var(--color-surface-lowest)',
    color: disabled ? 'var(--color-text-muted)' : 'var(--color-text-heading)',
    cursor: disabled ? 'default' : 'pointer', opacity: disabled ? 0.45 : 1,
  };
}

function StackedBarChart({
  data = [], categories = [], labelKey = 'label',
  valueFormat = 'number', height = 268,
}) {
  const [page, setPage] = useState(0);
  const needsPagination = data.length > PAGE_SIZE;
  const totalPages = Math.ceil(data.length / PAGE_SIZE);
  const visibleData = needsPagination
    ? data.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE)
    : data;

  const start = page * PAGE_SIZE + 1;
  const end = Math.min((page + 1) * PAGE_SIZE, data.length);

  return (
    <div>
      <div style={{ width: '100%', height }}>
        <ResponsiveContainer>
          <BarChart data={visibleData} layout="vertical" margin={{ top: 8, right: 4, bottom: 0, left: 4 }}>
            <CartesianGrid horizontal={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
            <XAxis type="number" tickLine={false} axisLine={false}
              tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
              tickFormatter={(value) => formatValue(value, valueFormat)} />
            <YAxis type="category" dataKey={labelKey} width={112} tickLine={false} axisLine={false}
              tick={{ fill: 'var(--color-text-body)', fontSize: 12 }} />
            <Tooltip cursor={{ fill: 'rgba(0, 101, 101, 0.05)' }}
              formatter={(value, key) => [formatValue(value, valueFormat), key]}
              contentStyle={{ border: 'none', borderRadius: 12, boxShadow: 'var(--shadow-float)' }} />
            <Legend wrapperStyle={{ fontSize: 11, color: 'var(--color-text-body)' }} />
            {categories.map((category, index) => (
              <Bar key={category.key} dataKey={category.key} name={category.label} stackId="stack"
                fill={category.color || DEFAULT_COLORS[index % DEFAULT_COLORS.length]}
                radius={0} maxBarSize={18} />
            ))}
          </BarChart>
        </ResponsiveContainer>
      </div>

      {needsPagination && (
        <div style={paginatorStyle}>
          <span style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)' }}>
            Mostrando {start} a {end} de {data.length} registros
          </span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <button type="button" onClick={() => setPage((p) => Math.max(0, p - 1))}
              disabled={page === 0} style={navBtnStyle(page === 0)} aria-label="Anterior">
              <ChevronLeft size={16} />
            </button>
            <span style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)' }}>
              {page + 1} / {totalPages}
            </span>
            <button type="button" onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
              disabled={page >= totalPages - 1} style={navBtnStyle(page >= totalPages - 1)} aria-label="Siguiente">
              <ChevronRight size={16} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default StackedBarChart;
