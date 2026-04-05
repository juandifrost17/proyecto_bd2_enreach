import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react';
import { DEFAULT_PERIOD, PERIOD_FILTER_TYPES } from '@/constants/api';
import {
  buildPeriodMeta,
  clampPeriodValue,
  normalizePeriodInput,
} from '@/utils/period';

const PeriodContext = createContext(null);

function createInitialPeriod(initialValue) {
  return normalizePeriodInput({
    ...DEFAULT_PERIOD,
    ...initialValue,
  });
}

export function PeriodProvider({ children, initialValue }) {
  const [period, setPeriodState] = useState(() => createInitialPeriod(initialValue));

  const setPeriod = useCallback((nextValue) => {
    setPeriodState((current) => {
      const incoming = typeof nextValue === 'function' ? nextValue(current) : nextValue;
      return normalizePeriodInput({ ...current, ...incoming });
    });
  }, []);

  const setYear = useCallback((anio) => {
    setPeriodState((current) => normalizePeriodInput({ ...current, anio }));
  }, []);

  const setPeriodValue = useCallback((periodo) => {
    setPeriodState((current) => normalizePeriodInput({ ...current, periodo }));
  }, []);

  const setFilterType = useCallback((tipoFiltro) => {
    setPeriodState((current) => {
      const normalizedType = String(tipoFiltro || '').toUpperCase();
      const safeType = Object.values(PERIOD_FILTER_TYPES).includes(normalizedType)
        ? normalizedType
        : current.tipoFiltro;

      return normalizePeriodInput({
        ...current,
        tipoFiltro: safeType,
        periodo: clampPeriodValue(current.periodo, safeType),
      });
    });
  }, []);

  const resetPeriod = useCallback(() => {
    setPeriodState(createInitialPeriod(initialValue));
  }, [initialValue]);

  const value = useMemo(() => ({
    period,
    periodMeta: buildPeriodMeta(period),
    setPeriod,
    setYear,
    setPeriodValue,
    setFilterType,
    resetPeriod,
  }), [period, resetPeriod, setFilterType, setPeriod, setPeriodValue, setYear]);

  return <PeriodContext.Provider value={value}>{children}</PeriodContext.Provider>;
}

export function usePeriodContext() {
  const context = useContext(PeriodContext);

  if (!context) {
    throw new Error('usePeriodContext must be used inside PeriodProvider.');
  }

  return context;
}

export function usePeriod() {
  return usePeriodContext().period;
}

export function usePeriodMeta() {
  return usePeriodContext().periodMeta;
}

export function usePeriodActions() {
  const {
    setPeriod,
    setYear,
    setPeriodValue,
    setFilterType,
    resetPeriod,
  } = usePeriodContext();

  return {
    setPeriod,
    setYear,
    setPeriodValue,
    setFilterType,
    resetPeriod,
  };
}
