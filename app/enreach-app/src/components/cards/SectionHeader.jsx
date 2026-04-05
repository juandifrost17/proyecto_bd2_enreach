import styles from './SectionHeader.module.css';

function SectionHeader({ title }) {
  return (
    <header className={styles.header}>
      <span className={styles.bar} aria-hidden="true" />
      <h2 className={styles.title}>{title}</h2>
    </header>
  );
}

export default SectionHeader;
