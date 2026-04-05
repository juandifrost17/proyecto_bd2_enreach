import EmptyState from './EmptyState';
import ErrorState from './ErrorState';
import LoadingSkeleton from './LoadingSkeleton';

function toErrorMessage(error) {
  if (!error) return 'No fue posible cargar este módulo.';
  if (typeof error === 'string') return error;
  return error.message || 'No fue posible cargar este módulo.';
}

function ReportState({
  report,
  onRetry,
  skeleton = 'card',
  emptyTitle,
  emptyDescription,
  children,
}) {
  if (!report || report.loading) {
    return <LoadingSkeleton variant={skeleton} />;
  }

  if (report.status === 'error') {
    return <ErrorState message={toErrorMessage(report.error)} onRetry={onRetry} />;
  }

  if (report.status === 'empty' || report.data == null) {
    return <EmptyState title={emptyTitle} description={emptyDescription} />;
  }

  return children(report.data, report.rawData);
}

export default ReportState;
