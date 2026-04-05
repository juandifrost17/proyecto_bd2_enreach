import { useEffect, useMemo, useState } from 'react';
import CriticalityDot from '@/components/status/CriticalityDot';
import RiskBadge from '@/components/status/RiskBadge';
import StatusChip from '@/components/status/StatusChip';
import { formatCompactNumber, formatCurrencyCompact, formatPercent } from '@/utils/formatters';
import Pagination from './Pagination';
import styles from './DataTable.module.css';

function defaultFormatter(value) {
  if (value === null || value === undefined || value === '') return '—';
  return value;
}

function formatCellValue(rawValue, row, column) {
  if (column.render) {
    return column.render(rawValue, row);
  }

  if (column.formatter) {
    return column.formatter(rawValue, row);
  }

  switch (column.format) {
    case 'currency':
      return formatCurrencyCompact(rawValue);
    case 'percent':
      return formatPercent(rawValue);
    case 'days':
      return `${Number(rawValue || 0)} d`;
    case 'integer':
      return formatCompactNumber(rawValue, 'es-EC', { maximumFractionDigits: 0 });
    case 'risk':
      return <RiskBadge level={rawValue} />;
    case 'sla':
      return <CriticalityDot level={rawValue} />;
    case 'status':
      return <StatusChip status={rawValue} size="sm" />;
    default:
      return defaultFormatter(rawValue);
  }
}

function DataTable({ columns = [], rows = [], pageSize = 5, renderEmpty }) {
  const [page, setPage] = useState(1);

  const maxPage = Math.max(1, Math.ceil(rows.length / pageSize));

  useEffect(() => {
    if (page > maxPage) {
      setPage(maxPage);
    }
  }, [maxPage, page]);

  const pageRows = useMemo(() => {
    const start = (page - 1) * pageSize;
    return rows.slice(start, start + pageSize);
  }, [page, pageSize, rows]);

  if (!rows.length && renderEmpty) {
    return renderEmpty();
  }

  return (
    <div className={styles.tableWrap}>
      <div className={styles.scroller}>
        <table className={styles.table}>
          <thead>
            <tr>
              {columns.map((column) => (
                <th key={column.key} className={`${styles.head} ${styles[column.align || 'left']}`.trim()}>
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {pageRows.map((row, rowIndex) => (
              <tr key={row.id ?? rowIndex} className={styles.row}>
                {columns.map((column) => {
                  const rawValue = row[column.key];
                  const content = formatCellValue(rawValue, row, column);

                  return (
                    <td key={column.key} className={`${styles.cell} ${styles[column.align || 'left']}`.trim()}>
                      {content}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {rows.length > pageSize ? (
        <Pagination total={rows.length} pageSize={pageSize} currentPage={page} onPageChange={setPage} />
      ) : null}
    </div>
  );
}

export default DataTable;
