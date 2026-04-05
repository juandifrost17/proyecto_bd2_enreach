import { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { formatCurrencyCompact, formatCurrency } from '@/utils/formatters';

const PAGE_SIZE = 5;

const BUCKETS = [
  { key: '0-30 dias',  label: '0–30 d',  color: 'var(--color-chart-primary)',    bg: 'rgba(0,101,101,0.12)'  },
  { key: '31-60 dias', label: '31–60 d', color: '#e65100',                       bg: 'rgba(230,81,0,0.12)'   },
  { key: '61-90 dias', label: '61–90 d', color: '#f9a825',                       bg: 'rgba(249,168,37,0.12)' },
  { key: '> 90 dias',  label: '+90 d',   color: 'var(--color-status-critical)',   bg: 'rgba(198,40,40,0.12)'  },
];

function getWorstBucket(row) {
  for (let i = BUCKETS.length - 1; i >= 0; i--) {
    if ((row[BUCKETS[i].key] || 0) > 0) return BUCKETS[i];
  }
  return BUCKETS[0];
}

function navBtnStyle(disabled) {
  return {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
    width: 28, height: 28, border: '1px solid var(--color-chart-grid)', borderRadius: 6,
    background: disabled ? 'var(--color-surface-low)' : 'var(--color-surface-lowest)',
    color: disabled ? 'var(--color-text-muted)' : 'var(--color-text-heading)',
    cursor: disabled ? 'default' : 'pointer', opacity: disabled ? 0.45 : 1,
  };
}

function AgingCarteraChart({ data = [] }) {
  const [page, setPage] = useState(0);
  const [hovered, setHovered] = useState(null);

  // Aggregate per client
  const clients = data.reduce((acc, row) => {
    if (!acc[row.label]) acc[row.label] = { label: row.label };
    BUCKETS.forEach((b) => {
      acc[row.label][b.key] = (acc[row.label][b.key] || 0) + (row[b.key] || 0);
    });
    return acc;
  }, {});

  const rows = Object.values(clients).map((c) => ({
    ...c,
    total: BUCKETS.reduce((s, b) => s + (c[b.key] || 0), 0),
  })).sort((a, b) => b.total - a.total);

  const maxTotal = Math.max(...rows.map((r) => r.total), 1);
  const totalPages = Math.ceil(rows.length / PAGE_SIZE);
  const visible = rows.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      {/* Legend */}
      <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', marginBottom: '1rem' }}>
        {BUCKETS.map((b) => (
          <div key={b.key} style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
            <span style={{ width: 10, height: 10, borderRadius: 2, background: b.color, display: 'inline-block' }} />
            <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>{b.label}</span>
          </div>
        ))}
      </div>

      {/* Rows */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.55rem' }}>
        {visible.map((row) => {
          const worst = getWorstBucket(row);
          const isHov = hovered === row.label;
          return (
            <div
              key={row.label}
              onMouseEnter={() => setHovered(row.label)}
              onMouseLeave={() => setHovered(null)}
              style={{
                padding: '0.55rem 0.75rem',
                borderRadius: 8,
                background: isHov ? worst.bg : 'transparent',
                transition: 'background 0.15s',
                cursor: 'default',
              }}
            >
              {/* Client name + total */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '0.35rem' }}>
                <span style={{ fontSize: '0.8rem', fontWeight: 500, color: 'var(--color-text-heading)', maxWidth: '65%', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {row.label}
                </span>
                <span style={{ fontSize: '0.78rem', fontWeight: 600, color: worst.color }}>
                  {formatCurrencyCompact(row.total)}
                </span>
              </div>

              {/* Stacked bar */}
              <div style={{ display: 'flex', height: 8, borderRadius: 4, overflow: 'hidden', background: 'var(--color-surface-high)', width: '100%' }}>
                {BUCKETS.map((b) => {
                  const val = row[b.key] || 0;
                  const pct = (val / maxTotal) * 100;
                  if (!pct) return null;
                  return (
                    <div
                      key={b.key}
                      title={`${b.label}: ${formatCurrency(val)}`}
                      style={{ width: `${pct}%`, background: b.color, transition: 'width 0.3s' }}
                    />
                  );
                })}
              </div>

              {/* Bucket breakdown on hover */}
              {isHov && (
                <div style={{ display: 'flex', gap: '0.75rem', marginTop: '0.4rem', flexWrap: 'wrap' }}>
                  {BUCKETS.map((b) => {
                    const val = row[b.key] || 0;
                    if (!val) return null;
                    return (
                      <span key={b.key} style={{ fontSize: '0.72rem', color: b.color, fontWeight: 500 }}>
                        {b.label}: {formatCurrencyCompact(val)}
                      </span>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Pagination */}
      {rows.length > PAGE_SIZE && (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: '0.75rem' }}>
          <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>
            {rows.length} clientes con saldo pendiente
          </span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
            <button type="button" onClick={() => setPage((p) => Math.max(0, p - 1))}
              disabled={page === 0} style={navBtnStyle(page === 0)} aria-label="Anterior">
              <ChevronLeft size={14} />
            </button>
            <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>{page + 1} / {totalPages}</span>
            <button type="button" onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
              disabled={page >= totalPages - 1} style={navBtnStyle(page >= totalPages - 1)} aria-label="Siguiente">
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      )}

      {rows.length === 0 && (
        <p style={{ textAlign: 'center', color: 'var(--color-text-muted)', fontSize: '0.85rem', padding: '2rem 0' }}>
          Sin saldo pendiente en el período
        </p>
      )}
    </div>
  );
}

export default AgingCarteraChart;
