import { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { formatCompactNumber, formatPercent } from '@/utils/formatters';

function FilialFunnelChart({ data = [] }) {
  const [open, setOpen] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(0);

  if (!data.length) return (
    <p style={{ textAlign: 'center', color: 'var(--color-text-muted)', fontSize: '0.85rem', padding: '2rem 0' }}>
      Sin datos de embudo
    </p>
  );

  const selected = data[selectedIndex] ?? data[0];
  const { label, intentos, logrados, fallidos, efectividad } = selected;

  // Build funnel stages from this filial
  const stages = [
    {
      key: 'intentos',
      label: 'Intentos totales',
      value: intentos,
      pct: 100,
      color: 'var(--color-chart-primary)',
      alpha: 1,
    },
    {
      key: 'logrados',
      label: 'Logrados',
      value: logrados,
      pct: intentos > 0 ? (logrados / intentos) * 100 : 0,
      color: 'var(--color-chart-primary)',
      alpha: 0.65,
    },
    {
      key: 'fallidos',
      label: 'Fallidos',
      value: fallidos,
      pct: intentos > 0 ? (fallidos / intentos) * 100 : 0,
      color: 'var(--color-status-critical)',
      alpha: 0.75,
    },
  ];

  const maxWidth = 320;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
      {/* Filial selector */}
      <div style={{ position: 'relative', alignSelf: 'flex-start', minWidth: 200 }}>
        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          style={{
            display: 'flex', alignItems: 'center', gap: '0.5rem',
            padding: '0.4rem 0.75rem',
            border: '1px solid var(--color-chart-grid)',
            borderRadius: 8, background: 'var(--color-surface-lowest)',
            cursor: 'pointer', fontSize: '0.8rem', color: 'var(--color-text-heading)',
            fontWeight: 500, width: '100%',
          }}
        >
          <span style={{ flex: 1, textAlign: 'left', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {label}
          </span>
          <ChevronDown size={14} style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s', flexShrink: 0 }} />
        </button>

        {open && (
          <div style={{
            position: 'absolute', top: '110%', left: 0, right: 0, zIndex: 20,
            background: 'var(--color-surface-lowest)',
            border: '1px solid var(--color-chart-grid)',
            borderRadius: 8, boxShadow: 'var(--shadow-float)',
            overflow: 'hidden',
          }}>
            {data.map((filial, idx) => (
              <button
                key={filial.id}
                type="button"
                onClick={() => { setSelectedIndex(idx); setOpen(false); }}
                style={{
                  display: 'block', width: '100%', textAlign: 'left',
                  padding: '0.45rem 0.75rem', fontSize: '0.8rem',
                  background: idx === selectedIndex ? 'var(--color-primary-light)' : 'transparent',
                  color: idx === selectedIndex ? 'var(--color-primary)' : 'var(--color-text-body)',
                  fontWeight: idx === selectedIndex ? 600 : 400,
                  cursor: 'pointer', border: 'none',
                }}
              >
                {filial.label}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Funnel */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.3rem', padding: '0.5rem 0' }}>
        {stages.map((stage, idx) => {
          const barWidth = Math.max((stage.pct / 100) * maxWidth, 60);
          const isLast = idx === stages.length - 1;

          return (
            <div key={stage.key} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', width: '100%' }}>
              {/* Trapezoid bar */}
              <div style={{
                width: barWidth,
                height: 44,
                background: stage.color,
                opacity: stage.alpha,
                borderRadius: idx === 0 ? '6px 6px 0 0' : isLast ? '0 0 6px 6px' : 0,
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                transition: 'width 0.4s ease',
                position: 'relative',
              }}>
                <span style={{ fontSize: '0.78rem', fontWeight: 700, color: 'white' }}>
                  {formatCompactNumber(stage.value)}
                </span>
                <span style={{ fontSize: '0.65rem', color: 'rgba(255,255,255,0.85)' }}>
                  {stage.pct < 100 ? formatPercent(stage.pct) : '100%'}
                </span>
              </div>

              {/* Label outside */}
              <div style={{
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                gap: '0.35rem', marginTop: '0.2rem', marginBottom: isLast ? 0 : '0.15rem',
              }}>
                <span style={{
                  fontSize: '0.72rem',
                  color: stage.key === 'fallidos' ? 'var(--color-status-critical)' : 'var(--color-text-muted)',
                  fontWeight: 500,
                }}>
                  {stage.label}
                </span>
              </div>

              {/* Arrow between stages */}
              {!isLast && (
                <svg width={12} height={10} style={{ margin: '0.05rem 0' }}>
                  <polygon points="0,0 12,0 6,10" fill="var(--color-chart-grid)" />
                </svg>
              )}
            </div>
          );
        })}
      </div>

      {/* Efectividad summary */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem',
        padding: '0.5rem 1rem',
        background: efectividad >= 70 ? 'var(--color-status-ok-bg)' : efectividad >= 40 ? 'var(--color-status-warning-bg)' : 'var(--color-status-critical-bg)',
        borderRadius: 8,
      }}>
        <span style={{ fontSize: '0.78rem', color: 'var(--color-text-body)' }}>Efectividad total:</span>
        <span style={{
          fontSize: '1rem', fontWeight: 700,
          color: efectividad >= 70 ? 'var(--color-status-ok)' : efectividad >= 40 ? 'var(--color-status-warning)' : 'var(--color-status-critical)',
        }}>
          {formatPercent(efectividad)}
        </span>
      </div>

      {/* Filial count */}
      {data.length > 1 && (
        <p style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', textAlign: 'center' }}>
          {data.length} filiales · usa el selector para cambiar de filial
        </p>
      )}
    </div>
  );
}

export default FilialFunnelChart;
