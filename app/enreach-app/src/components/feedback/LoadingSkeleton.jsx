import styles from './LoadingSkeleton.module.css';

function LoadingSkeleton({ variant = 'card' }) {
  return <div className={`${styles.skeleton} ${styles[variant] || styles.card}`.trim()} aria-hidden="true" />;
}

export default LoadingSkeleton;
