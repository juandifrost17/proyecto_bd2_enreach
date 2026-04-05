import styles from './RiskBadge.module.css';

function RiskBadge({ level = 'medio' }) {
  const normalized = String(level || '').toLowerCase();
  const tone = normalized === 'alto' || normalized === 'critical'
    ? 'critical'
    : normalized === 'bajo' || normalized === 'ok'
      ? 'ok'
      : 'warning';

  const label = normalized === 'critical'
    ? 'ALTO'
    : normalized === 'warning'
      ? 'MEDIO'
      : normalized === 'ok'
        ? 'BAJO'
        : normalized.toUpperCase();

  return <span className={`${styles.badge} ${styles[tone]}`.trim()}>{label}</span>;
}

export default RiskBadge;
