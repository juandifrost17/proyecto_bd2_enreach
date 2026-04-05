import KpiCard from './KpiCard';
import styles from './KpiStrip.module.css';

function KpiStrip({ items = [] }) {
  return (
    <section className={styles.strip}>
      {items.map((item) => (
        <KpiCard key={item.label} {...item} />
      ))}
    </section>
  );
}

export default KpiStrip;
