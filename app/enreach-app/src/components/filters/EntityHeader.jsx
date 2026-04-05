import StatusChip from '@/components/status/StatusChip';
import styles from './EntityHeader.module.css';

function EntityHeader({ name, status = null, metadata = [] }) {
  return (
    <section className={styles.header}>
      <div className={styles.copy}>
        <div className={styles.row}>
          <p className={styles.name}>{name}</p>
          {/* Only render chip when status is known — avoids showing ACTIVO for inactive entities */}
          {status && <StatusChip status={status} />}
        </div>
        {metadata.length ? (
          <div className={styles.metaRow}>
            {metadata.map((item) => (
              <span key={item.label} className={styles.metaItem}>
                <span className={styles.metaLabel}>{item.label}</span>
                <span className={styles.metaValue}>{item.value}</span>
              </span>
            ))}
          </div>
        ) : null}
      </div>
    </section>
  );
}

export default EntityHeader;
