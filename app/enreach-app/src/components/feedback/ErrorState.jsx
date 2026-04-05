import { AlertOctagon } from 'lucide-react';
import styles from './ErrorState.module.css';

function ErrorState({ message = 'No fue posible cargar este módulo.', onRetry }) {
  return (
    <div className={styles.state} role="alert">
      <div className={styles.iconWrap}>
        <AlertOctagon size={18} strokeWidth={1.9} aria-hidden="true" />
      </div>
      <h3 className={styles.title}>Error de carga</h3>
      <p className={styles.message}>{message}</p>
      {onRetry ? (
        <button className={styles.button} type="button" onClick={onRetry}>
          Reintentar
        </button>
      ) : null}
    </div>
  );
}

export default ErrorState;
