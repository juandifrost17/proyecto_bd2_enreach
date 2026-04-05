import styles from './CriticalityDot.module.css';

function CriticalityDot({ level = 'ok' }) {
  return <span className={`${styles.dot} ${styles[level] || styles.ok}`.trim()} aria-label={`criticidad ${level}`} />;
}

export default CriticalityDot;
