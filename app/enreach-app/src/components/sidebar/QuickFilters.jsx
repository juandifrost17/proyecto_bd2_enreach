import { AlertTriangle, CircleDollarSign, ShieldAlert } from 'lucide-react';
import styles from './QuickFilters.module.css';

const FILTER_META = {
  critical: { label: 'Solo críticos', Icon: AlertTriangle },
  mora: { label: 'Solo con mora', Icon: CircleDollarSign },
  sla: { label: 'Solo fuera de SLA', Icon: ShieldAlert },
};

function QuickFilters({ filters = {}, onToggle, disabledKeys = [] }) {
  const disabledSet = new Set(disabledKeys);

  return (
    <div className={styles.group}>
      {Object.entries(FILTER_META).map(([key, meta]) => {
        const active = Boolean(filters[key]);
        const disabled = disabledSet.has(key);
        const { Icon, label } = meta;

        return (
          <button
            key={key}
            type="button"
            className={`${styles.item} ${active ? styles.active : ''} ${disabled ? styles.disabled : ''}`.trim()}
            onClick={() => {
              if (!disabled) onToggle?.(key);
            }}
            aria-pressed={active}
            aria-disabled={disabled}
            title={disabled ? 'Filtro no disponible para este dataset.' : undefined}
          >
            <Icon size={15} strokeWidth={1.85} aria-hidden="true" />
            <span>{label}</span>
          </button>
        );
      })}
    </div>
  );
}

export default QuickFilters;
