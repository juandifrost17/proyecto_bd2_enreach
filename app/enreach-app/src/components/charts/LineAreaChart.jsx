import {
  Area,
  AreaChart,
  CartesianGrid,
  Line,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { formatCompactNumber, formatCurrencyCompact } from '@/utils/formatters';

function formatValue(value, valueFormat) {
  if (valueFormat === 'currency') return formatCurrencyCompact(value);
  return formatCompactNumber(value);
}

function LineAreaChart({
  data = [],
  xKey = 'label',
  primaryLine = 'actual',
  referenceLine = 'reference',
  primaryLabel = 'Actual',
  referenceLabel = 'Referencia',
  valueFormat = 'currency',
  height = 284,
}) {
  return (
    <div style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <AreaChart data={data} margin={{ top: 8, right: 4, bottom: 0, left: 0 }}>
          <defs>
            <linearGradient id="enreachArea" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="var(--color-chart-primary)" stopOpacity={0.22} />
              <stop offset="95%" stopColor="var(--color-chart-primary)" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid stroke="var(--color-chart-grid)" strokeDasharray="3 3" vertical={false} />
          <XAxis dataKey={xKey} tickLine={false} axisLine={false} tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} />
          <YAxis tickLine={false} axisLine={false} tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} tickFormatter={(value) => formatValue(value, valueFormat)} />
          <Tooltip
            formatter={(value, name) => [formatValue(value, valueFormat), name === primaryLine ? primaryLabel : referenceLabel]}
            contentStyle={{ border: 'none', borderRadius: 12, boxShadow: 'var(--shadow-float)' }}
          />
          <Area type="monotone" dataKey={primaryLine} name={primaryLabel} stroke="var(--color-chart-primary)" fill="url(#enreachArea)" strokeWidth={2.2} />
          <Line type="monotone" dataKey={referenceLine} name={referenceLabel} stroke="var(--color-chart-secondary)" strokeDasharray="6 4" strokeWidth={1.8} dot={false} />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}

export default LineAreaChart;
