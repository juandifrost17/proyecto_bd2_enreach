import styles from './BrandHeader.module.css';

function BrandHeader({ label = 'Analytics', compact = false, className = '' }) {
  return (
    <div className={`${styles.brand} ${compact ? styles.compact : ''} ${className}`.trim()}>
      <img className={styles.logo} src="/enreach.svg" alt="Enreach Analytics" />
      <div className={styles.copy}>
        <span className={styles.name}>Enreach</span>
        <span className={styles.label}>{label}</span>
      </div>
    </div>
  );
}

export default BrandHeader;
