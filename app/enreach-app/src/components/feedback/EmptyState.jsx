import { Inbox } from 'lucide-react';
import styles from './EmptyState.module.css';

function EmptyState({ title = 'Sin datos', description = 'No hay información disponible para el periodo seleccionado.' }) {
  return (
    <div className={styles.state} role="status">
      <div className={styles.iconWrap}>
        <Inbox size={18} strokeWidth={1.9} aria-hidden="true" />
      </div>
      <h3 className={styles.title}>{title}</h3>
      <p className={styles.description}>{description}</p>
    </div>
  );
}

export default EmptyState;
