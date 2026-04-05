import styles from './StatusChip.module.css';

const STATUS_MAP = {
  activo: 'ok',
  pagada: 'ok',
  estable: 'ok',
  pendiente: 'warning',
  alerta: 'warning',
  en_riesgo: 'critical',
  critico: 'critical',
};

function StatusChip({ status = 'activo', size = 'md' }) {
  const key = String(status || '').toLowerCase();
  const tone = STATUS_MAP[key] || 'neutral';
  const label = String(status || 'sin estado').replace(/_/g, ' ');

  return <span className={`${styles.chip} ${styles[tone]} ${styles[size] || ''}`.trim()}>{label}</span>;
}

export default StatusChip;
