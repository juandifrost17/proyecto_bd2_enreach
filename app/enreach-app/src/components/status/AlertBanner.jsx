import { AlertTriangle } from 'lucide-react';
import styles from './AlertBanner.module.css';

function AlertBanner({ message, variant = 'warning', compact = false }) {
  return (
    <div className={`${styles.banner} ${styles[variant] || styles.warning} ${compact ? styles.compact : ''}`.trim()}>
      <AlertTriangle size={compact ? 14 : 16} strokeWidth={1.9} aria-hidden="true" />
      <span>{message}</span>
    </div>
  );
}

export default AlertBanner;
