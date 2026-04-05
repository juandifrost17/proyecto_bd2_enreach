import styles from './RiskBarChart.module.css';
import RiskBadge from '@/components/status/RiskBadge';
import { formatCurrencyCompact } from '@/utils/formatters';

function RiskBarChart({ data = [], valueKey = 'value', riskKey = 'risk', labelKey = 'label' }) {
  const maxValue = Math.max(...data.map((item) => Number(item[valueKey]) || 0), 1);

  return (
    <div className={styles.stack}>
      {data.map((item) => {
        const ratio = ((Number(item[valueKey]) || 0) / maxValue) * 100;
        return (
          <article key={item[labelKey]} className={styles.row}>
            <div className={styles.rowHeader}>
              <div>
                <h4 className={styles.label}>{item[labelKey]}</h4>
                <p className={styles.value}>{formatCurrencyCompact(item[valueKey])}</p>
              </div>
              <RiskBadge level={item[riskKey]} />
            </div>
            <div className={styles.track}>
              <div className={`${styles.fill} ${styles[item[riskKey]] || ''}`.trim()} style={{ width: `${ratio}%` }} />
            </div>
          </article>
        );
      })}
    </div>
  );
}

export default RiskBarChart;
