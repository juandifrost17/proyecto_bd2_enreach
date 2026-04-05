import { useCallback, useEffect, useRef, useState } from 'react';
import searchApi from '@/api/search.api';

const DEBOUNCE_MS = 300;
const MIN_QUERY_LENGTH = 3;

export default function useEntitySearch(audience) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);
  const controllerRef = useRef(null);
  const timerRef = useRef(null);

  const search = useCallback((term) => {
    if (controllerRef.current) {
      controllerRef.current.abort();
    }

    const trimmed = term.trim();
    if (trimmed.length < MIN_QUERY_LENGTH) {
      setResults([]);
      setLoading(false);
      setOpen(false);
      return;
    }

    setLoading(true);
    const controller = new AbortController();
    controllerRef.current = controller;

    const fetcher = audience === 'partner'
      ? searchApi.searchPartners
      : searchApi.searchClientes;

    fetcher(trimmed, controller.signal)
      .then((data) => {
        if (!controller.signal.aborted) {
          setResults(Array.isArray(data) ? data : []);
          setOpen(true);
          setLoading(false);
        }
      })
      .catch((error) => {
        if (error?.name !== 'AbortError') {
          setResults([]);
          setLoading(false);
        }
      });
  }, [audience]);

  useEffect(() => {
    clearTimeout(timerRef.current);

    if (query.trim().length < MIN_QUERY_LENGTH) {
      setResults([]);
      setOpen(false);
      return;
    }

    timerRef.current = setTimeout(() => search(query), DEBOUNCE_MS);

    return () => clearTimeout(timerRef.current);
  }, [query, search]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      clearTimeout(timerRef.current);
      if (controllerRef.current) {
        controllerRef.current.abort();
      }
    };
  }, []);

  // Reset when audience changes
  useEffect(() => {
    setQuery('');
    setResults([]);
    setOpen(false);
  }, [audience]);

  const close = useCallback(() => setOpen(false), []);

  return { query, setQuery, results, loading, open, close };
}
