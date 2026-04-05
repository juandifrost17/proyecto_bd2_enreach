import { Clock } from 'lucide-react';

const style = {
  display: 'inline-flex',
  alignItems: 'center',
  gap: '0.35rem',
  padding: '0.35rem 0.6rem',
  borderRadius: '0.65rem',
  background: 'rgba(0, 101, 101, 0.08)',
  color: 'var(--color-primary)',
  fontSize: '0.7rem',
  fontWeight: 500,
  letterSpacing: '0.02em',
};

function TimeBadge({ label = 'Solo por año' }) {
  return (
    <span style={style}>
      <Clock size={12} strokeWidth={2} />
      {label}
    </span>
  );
}

export default TimeBadge;
