import { useState } from 'react';
import {
  Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { formatCompactNumber, formatCurrencyCompact } from '@/utils/formatters';

const PAGE_SIZE = 5;

function formatValue(value, format) {
  if (format === 'currency') return formatCurrencyCompact(value);
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

function BarComparisonChart({
  data = [], primaryKey = 'primary', secondaryKey = 'secondary',
  labelKey = 'label', primaryLabel = 'Principal', secondaryLabel = 'Comparativo',
  valueFormat = 'currency', height = 320,
  reversed = false,   // when true: labels on right, bars extend left
}) {
  const [page, setPage] = useState(0);
  const needsPagination = data.length > PAGE_SIZE;
  const totalPages = Math.ceil(data.length / PAGE_SIZE);
  const visibleData = needsPagination
    ? data.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE)
    : data;

  const hasSecondary = Boolean(secondaryKey) && data.some((item) => item?.[secondaryKey] !== undefined);
  const rowHeight = hasSecondary ? 56 : 40;
  const chartHeight = Math.max(height, visibleData.length * rowHeight + 60);

  const start = page * PAGE_SIZE + 1;
  const end = Math.min((page + 1) * PAGE_SIZE, data.length);

  return (
    <div>
      <div style={{ width: '100%', height: chartHeight }}>
        <ResponsiveContainer>
          <BarChart data={visibleData} layout="vertical" margin={{ top: 4, right: 12, bottom: 4, left: 0 }} barGap={4} barCategoryGap="28%">
            <CartesianGrid horizontal={false} stroke="var(--color-chart-grid)" strokeDasharray="3 3" />
            <XAxis type="number" tickLine={false} axisLine={false}
              reversed={reversed}
              tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
              tickFormatter={(v) => formatValue(v, valueFormat)} />
            <YAxis type="category" dataKey={labelKey} width={140} tickLine={false} axisLine={false}
              orientation={reversed ? 'right' : 'left'}
              tick={{ fill: 'var(--color-text-body)', fontSize: 11 }} />
            <Tooltip cursor={{ fill: 'rgba(0, 101, 101, 0.04)' }}
              formatter={(value, name) => [formatValue(value, valueFormat), name]}
              contentStyle={{ border: 'none', borderRadius: 12, boxShadow: 'var(--shadow-float)' }} />
            <Legend verticalAlign="top" align="right" iconType="circle" iconSize={9}
              wrapperStyle={{ fontSize: '0.8rem', paddingBottom: 6 }} />
            <Bar dataKey={primaryKey} name={primaryLabel} fill="var(--color-chart-primary)"
              radius={[6, 6, 6, 6]} barSize={hasSecondary ? 14 : 18} />
            {hasSecondary && (
              <Bar dataKey={secondaryKey} name={secondaryLabel} fill="var(--color-chart-secondary)"
                radius={[6, 6, 6, 6]} barSize={14} />
            )}
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

export default BarComparisonChart;
