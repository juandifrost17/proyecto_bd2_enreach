import styles from './ChartCard.module.css';

function ChartCard({ title, subtitle, span = 1, actions, children }) {
  return (
    <article className={`${styles.card} ${span === 2 ? styles.spanTwo : ''}`.trim()}>
      <header className={styles.header}>
        <div>
          <h3 className={styles.title}>{title}</h3>
          {subtitle ? <p className={styles.subtitle}>{subtitle}</p> : null}
        </div>
        {actions ? <div className={styles.actions}>{actions}</div> : null}
      </header>

      <div className={styles.content}>{children}</div>
    </article>
  );
}

export default ChartCard;
