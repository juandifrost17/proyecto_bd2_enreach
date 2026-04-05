import { useEffect, useRef } from 'react';
import { Loader2, Search } from 'lucide-react';
import styles from './SearchBar.module.css';

function SearchBar({
  placeholder = 'Buscar entidad…',
  value = '',
  onChange,
  visible = true,
  disabled = false,
  loading = false,
  results = [],
  open = false,
  onSelect,
  onClose,
}) {
  const wrapRef = useRef(null);

  useEffect(() => {
    if (!open) return;

    function handleClickOutside(event) {
      if (wrapRef.current && !wrapRef.current.contains(event.target)) {
        onClose?.();
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [open, onClose]);

  if (!visible) {
    return null;
  }

  return (
    <div className={styles.searchWrap} ref={wrapRef}>
      <label className={styles.field}>
        {loading
          ? <Loader2 className={`${styles.icon} ${styles.spinner}`} size={16} strokeWidth={2} aria-hidden="true" />
          : <Search className={styles.icon} size={16} strokeWidth={2} aria-hidden="true" />
        }
        <input
          className={styles.input}
          type="text"
          value={value}
          onChange={(event) => onChange?.(event.target.value)}
          placeholder={placeholder}
          autoComplete="off"
          spellCheck="false"
          disabled={disabled}
          aria-label={placeholder}
        />
      </label>

      {open && results.length > 0 && (
        <ul className={styles.dropdown} role="listbox">
          {results.map((item) => (
            <li
              key={item.id}
              className={styles.dropdownItem}
              role="option"
              tabIndex={0}
              onClick={() => onSelect?.(item)}
              onKeyDown={(event) => {
                if (event.key === 'Enter') onSelect?.(item);
              }}
            >
              <span className={styles.itemName}>{item.nombre}</span>
              {item.estado && (
                <span className={`${styles.itemBadge} ${item.estado === 'ACTIVO' ? styles.itemBadgeActive : styles.itemBadgeInactive}`}>
                  {item.estado}
                </span>
              )}
            </li>
          ))}
        </ul>
      )}

      {value.trim().length > 0 && value.trim().length < 3 && !loading && (
        <div className={styles.helperText}>Escribe al menos 3 caracteres para buscar.</div>
      )}

      {open && value.trim().length >= 3 && results.length === 0 && !loading && (
        <div className={styles.dropdown}>
          <div className={styles.dropdownEmpty}>Sin resultados para "{value.trim()}"</div>
        </div>
      )}
    </div>
  );
}

export default SearchBar;
