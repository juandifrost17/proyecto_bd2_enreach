import styles from './AnalysisLevel.module.css';

export const ANALYSIS_LEVEL_OPTIONS = [
  { value: 'all', label: 'Todos los reportes' },
  { value: 'context', label: 'Contexto y tendencias' },
  { value: 'detail', label: 'Detalle granular' },
];

function AnalysisLevel({ value = 'all', onChange }) {
  return (
    <div className={styles.group} role="radiogroup" aria-label="Nivel de análisis">
      {ANALYSIS_LEVEL_OPTIONS.map((option) => {
        const active = value === option.value;
        return (
          <button
            key={option.value}
            type="button"
            className={`${styles.item} ${active ? styles.active : ''}`.trim()}
            onClick={() => onChange?.(option.value)}
            aria-pressed={active}
          >
            {option.label}
          </button>
        );
      })}
    </div>
  );
}

export default AnalysisLevel;
