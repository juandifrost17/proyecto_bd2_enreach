import { ChevronLeft, ChevronRight } from 'lucide-react';
import styles from './Pagination.module.css';

function Pagination({ total = 0, pageSize = 5, currentPage = 1, onPageChange }) {
  const totalPages = Math.max(1, Math.ceil(total / pageSize));
  const start = total === 0 ? 0 : (currentPage - 1) * pageSize + 1;
  const end = Math.min(currentPage * pageSize, total);

  return (
    <div className={styles.pagination}>
      <p className={styles.summary}>Mostrando {start} a {end} de {total} registros</p>
      <div className={styles.controls}>
        <button
          type="button"
          className={styles.nav}
          onClick={() => onPageChange?.(Math.max(1, currentPage - 1))}
          disabled={currentPage <= 1}
          aria-label="Página anterior"
        >
          <ChevronLeft size={16} strokeWidth={2} />
        </button>
        <span className={styles.page}>{currentPage}</span>
        <button
          type="button"
          className={styles.nav}
          onClick={() => onPageChange?.(Math.min(totalPages, currentPage + 1))}
          disabled={currentPage >= totalPages}
          aria-label="Página siguiente"
        >
          <ChevronRight size={16} strokeWidth={2} />
        </button>
      </div>
    </div>
  );
}

export default Pagination;
