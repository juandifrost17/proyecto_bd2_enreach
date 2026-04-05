import { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { formatCompactNumber, formatPercent } from '@/utils/formatters';

const PAGE_SIZE = 5;

function getRiskStyle(tasa) {
  if (tasa >= 30) return { bg: 'var(--color-status-critical-bg)', color: 'var(--color-status-critical)' };
  if (tasa >= 15) return { bg: 'var(--color-status-warning-bg)', color: 'var(--color-status-warning)' };
  return { bg: 'var(--color-status-ok-bg)', color: 'var(--color-status-ok)' };
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

function DeterioroLlamadasChart({ data = [] }) {
  const [page, setPage] = useState(0);
  const [hovered, setHovered] = useState(null);

  const sorted = [...data].sort((a, b) => b.variation - a.variation);
  const maxVolume = Math.max(...sorted.map((d) => d.value), 1);
  const totalPages = Math.ceil(sorted.length / PAGE_SIZE);
  const visible = sorted.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      {/* Header labels */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: '160px 1fr 80px 72px',
        gap: '0.5rem',
        paddingBottom: '0.5rem',
        borderBottom: '1px solid var(--color-chart-grid)',
        marginBottom: '0.25rem',
      }}>
        <span style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
          Cliente
        </span>
        <span style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
          Volumen
        </span>
        <span style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em', textAlign: 'right' }}>
          Total
        </span>
        <span style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em', textAlign: 'center' }}>
          % Pérdida
        </span>
      </div>

      {/* Rows */}
      {visible.map((row) => {
        const barPct = (row.value / maxVolume) * 100;
        const riskStyle = getRiskStyle(row.variation);
        const isHov = hovered === row.id;

        return (
          <div
            key={row.id}
            onMouseEnter={() => setHovered(row.id)}
            onMouseLeave={() => setHovered(null)}
            style={{
              display: 'grid',
              gridTemplateColumns: '160px 1fr 80px 72px',
              gap: '0.5rem',
              alignItems: 'center',
              padding: '0.45rem 0.25rem',
              borderRadius: 8,
              background: isHov ? 'var(--color-surface-low)' : 'transparent',
              transition: 'background 0.15s',
            }}
          >
            {/* Client name */}
            <span style={{
              fontSize: '0.8rem', color: 'var(--color-text-heading)',
              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
            }}>
              {row.label}
            </span>

            {/* Bar */}
            <div style={{ position: 'relative', height: 8, background: 'var(--color-surface-high)', borderRadius: 4, overflow: 'hidden' }}>
              <div style={{
                width: `${barPct}%`, height: '100%',
                background: 'var(--color-chart-primary)',
                borderRadius: 4,
                transition: 'width 0.3s',
              }} />
            </div>

            {/* Volume count */}
            <span style={{ fontSize: '0.78rem', color: 'var(--color-text-body)', textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>
              {formatCompactNumber(row.value)}
            </span>

            {/* Loss rate badge */}
            <div style={{ display: 'flex', justifyContent: 'center' }}>
              <span style={{
                display: 'inline-block',
                padding: '2px 7px',
                borderRadius: 6,
                fontSize: '0.72rem',
                fontWeight: 600,
                background: riskStyle.bg,
                color: riskStyle.color,
                whiteSpace: 'nowrap',
              }}>
                {formatPercent(row.variation)}
              </span>
            </div>
          </div>
        );
      })}

      {/* Legend note */}
      <p style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', marginTop: '0.5rem' }}>
        % Pérdida = variación de tasa de pérdida vs período anterior · 0% = sin cambio respecto al período previo
      </p>

      {/* Pagination */}
      {sorted.length > PAGE_SIZE && (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: '0.5rem' }}>
          <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>
            {sorted.length} clientes
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
    </div>
  );
}

export default DeterioroLlamadasChart;
