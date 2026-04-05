import { useCallback, useEffect, useMemo, useReducer, useRef, useState } from 'react';

function isObject(value) {
  return Object.prototype.toString.call(value) === '[object Object]';
}

export function isEmptyData(data) {
  if (data === null || data === undefined) return true;
  if (Array.isArray(data)) return data.length === 0;
  if (isObject(data)) return Object.keys(data).length === 0;
  return false;
}

function getErrorMessage(error) {
  if (!error) return null;
  if (typeof error === 'string') return error;
  return error.message || 'Unexpected error while fetching data.';
}

export default function useFetch(fetcher, deps = [], options = {}) {
  const {
    enabled = true,
    initialData = null,
    preserveDataOnRefetch = true,
    transform,
  } = options;

  const mountedRef = useRef(true);
  const requestIdRef = useRef(0);
  const [reloadKey, forceReload] = useReducer((value) => value + 1, 0);
  const [state, setState] = useState(() => ({
    data: initialData,
    rawData: initialData,
    loading: Boolean(enabled),
    error: null,
    status: enabled ? 'loading' : 'idle',
  }));

  useEffect(() => {
    return () => {
      mountedRef.current = false;
    };
  }, []);

  const runFetch = useCallback(() => {
    if (!enabled || typeof fetcher !== 'function') {
      setState((current) => ({
        ...current,
        loading: false,
        status: 'idle',
      }));
      return () => {};
    }

    const controller = new AbortController();
    const requestId = requestIdRef.current + 1;
    requestIdRef.current = requestId;

    setState((current) => ({
      data: preserveDataOnRefetch ? current.data : initialData,
      rawData: preserveDataOnRefetch ? current.rawData : initialData,
      loading: true,
      error: null,
      status: 'loading',
    }));

    Promise.resolve()
      .then(() => fetcher(controller.signal))
      .then((rawData) => {
        if (!mountedRef.current || requestId !== requestIdRef.current) {
          return;
        }

        const data = typeof transform === 'function' ? transform(rawData) : rawData;
        setState({
          data,
          rawData,
          loading: false,
          error: null,
          status: isEmptyData(data) ? 'empty' : 'success',
        });
      })
      .catch((error) => {
        if (error?.name === 'AbortError' || !mountedRef.current || requestId !== requestIdRef.current) {
          return;
        }

        setState((current) => ({
          data: preserveDataOnRefetch ? current.data : initialData,
          rawData: preserveDataOnRefetch ? current.rawData : initialData,
          loading: false,
          error,
          status: 'error',
        }));
      });

    return () => controller.abort();
  }, [enabled, fetcher, initialData, preserveDataOnRefetch, transform]);

  useEffect(() => runFetch(), [runFetch, reloadKey, ...deps]);

  const refetch = useCallback(() => {
    forceReload();
  }, []);

  return useMemo(() => ({
    ...state,
    errorMessage: getErrorMessage(state.error),
    isEmpty: state.status === 'empty',
    isSuccess: state.status === 'success',
    refetch,
  }), [refetch, state]);
}
