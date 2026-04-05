import { CalendarRange } from 'lucide-react';
import { DATA_YEARS, PERIOD_FILTER_TYPES } from '@/constants/api';
import { usePeriodActions, usePeriodContext } from '@/context/PeriodContext';
import styles from './PeriodSelector.module.css';

const FILTER_BUTTONS = [
  { value: PERIOD_FILTER_TYPES.QUARTER, label: 'Trimestre' },
  { value: PERIOD_FILTER_TYPES.YEAR, label: 'Año' },
];

function PeriodSelector() {
  const { period, periodMeta } = usePeriodContext();
  const { setFilterType, setPeriodValue, setYear } = usePeriodActions();

  return (
    <section className={styles.selector} aria-label="Selector de periodo">
      <div className={styles.segmented}>
        {FILTER_BUTTONS.map((filter) => {
          const active = period.tipoFiltro === filter.value;
          return (
            <button
              key={filter.value}
              type="button"
              className={`${styles.segment} ${active ? styles.segmentActive : ''}`.trim()}
              onClick={() => setFilterType(filter.value)}
              aria-pressed={active}
            >
              {filter.label}
            </button>
          );
        })}
      </div>

      <div className={styles.selectWrap}>
        <CalendarRange size={15} strokeWidth={1.9} aria-hidden="true" />
        <select
          className={styles.select}
          value={period.anio}
          onChange={(event) => setYear(Number(event.target.value))}
          aria-label="Año"
        >
          {DATA_YEARS.map((year) => (
            <option key={year} value={year}>{year}</option>
          ))}
        </select>
      </div>

      {period.tipoFiltro === PERIOD_FILTER_TYPES.QUARTER ? (
        <div className={styles.selectWrap}>
          <select
            className={styles.select}
            value={period.periodo}
            onChange={(event) => setPeriodValue(Number(event.target.value))}
            aria-label="Trimestre"
          >
            {periodMeta.periodOptions.map((option) => (
              <option key={option.value} value={option.value}>{option.label}</option>
            ))}
          </select>
        </div>
      ) : null}
    </section>
  );
}

export default PeriodSelector;
