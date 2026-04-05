import { useMemo } from 'react';
import { BellRing, CircleDollarSign, MessageSquareText, MessageSquareWarning, PhoneCall, Wallet } from 'lucide-react';
import { useOutletContext, useParams } from 'react-router-dom';
import ChartCard from '@/components/cards/ChartCard';
import SectionHeader from '@/components/cards/SectionHeader';
import BarComparisonChart from '@/components/charts/BarComparisonChart';
import BulletChart from '@/components/charts/BulletChart';
import FilialFunnelChart from '@/components/charts/FilialFunnelChart';
import HeatmapChart from '@/components/charts/HeatmapChart';
import LineAreaChart from '@/components/charts/LineAreaChart';
import YearBarChart from '@/components/charts/YearBarChart';
import EntityHeader from '@/components/filters/EntityHeader';
import PeriodSelector from '@/components/filters/PeriodSelector';
import EmptyState from '@/components/feedback/EmptyState';
import ReportState from '@/components/feedback/ReportState';
import KpiStrip from '@/components/kpis/KpiStrip';
import DataTable from '@/components/tables/DataTable';
import TimeBadge from '@/components/status/TimeBadge';
import { usePeriod } from '@/context/PeriodContext';
import {
  mapCostoPorInteraccionData,
  mapEmbudoContactoFilialData,
  mapHeatmapData,
  mapTendenciaComunicacionesData,
  mapUsoVsCapacidadSummary,
  mapUsuariosNoContestacionBarData,
} from '@/mappers/chart.mappers';
import { mapClienteKpis } from '@/mappers/kpi.mappers';
import { mapEstadoPagosTable, mapUsuariosNoContestacionTable, mapGruposColaboracionTable } from '@/mappers/table.mappers';
import { useClienteDashboardReports } from '@/hooks/useDashboardReports';
import useEntityName from '@/hooks/useEntityName';
import styles from './DashboardPage.module.css';
import { formatCompactNumber } from '@/utils/formatters';

const KPI_ICON_BY_ID = {
  gastoPeriodo: Wallet, montoPagado: CircleDollarSign, saldoPendiente: BellRing,
  usoMinutos: PhoneCall, usoMensajes: MessageSquareText, colasFueraSla: MessageSquareWarning,
};

function buildClienteKpiItems(dto) {
  return mapClienteKpis(dto).map((item) => ({ ...item, icon: KPI_ICON_BY_ID[item.id] }));
}

function ClienteDashboard() {
  const { id } = useParams();
  const { audience } = useOutletContext();
  const period = usePeriod();
  const { reports, refetch } = useClienteDashboardReports(id, period);
  const { name: clienteName, status: clienteStatus } = useEntityName('cliente', id, '');

  const kpiItems = useMemo(() => buildClienteKpiItems(reports.kpis?.rawData ?? {}), [reports.kpis?.rawData]);
  const tendenciaData = useMemo(() => mapTendenciaComunicacionesData(reports.tendenciaComunicaciones?.rawData ?? []), [reports.tendenciaComunicaciones?.rawData]);
  const costoData = useMemo(() => mapCostoPorInteraccionData(reports.costoPorInteraccion?.rawData ?? []), [reports.costoPorInteraccion?.rawData]);
  const usoCapacidadItems = useMemo(() => mapUsoVsCapacidadSummary(reports.usoVsCapacidad?.rawData ?? []), [reports.usoVsCapacidad?.rawData]);
  const saturacionData = useMemo(() => mapHeatmapData(reports.saturacionHoraria?.rawData ?? []), [reports.saturacionHoraria?.rawData]);
  const embudoData = useMemo(() => mapEmbudoContactoFilialData(reports.embudoContactoFilial?.rawData ?? []), [reports.embudoContactoFilial?.rawData]);
  const pagosTable = useMemo(() => mapEstadoPagosTable(reports.estadoPagos?.rawData ?? []), [reports.estadoPagos?.rawData]);
  const usuariosTable = useMemo(() => mapUsuariosNoContestacionTable(reports.usuariosNoContestacion?.rawData ?? []), [reports.usuariosNoContestacion?.rawData]);
  const usuariosChartData = useMemo(() => mapUsuariosNoContestacionBarData(reports.usuariosNoContestacion?.rawData ?? []), [reports.usuariosNoContestacion?.rawData]);
  const gruposTable = useMemo(() => mapGruposColaboracionTable(reports.gruposColaboracion?.rawData ?? []), [reports.gruposColaboracion?.rawData]);

  const pageClassName = styles.page;

  return (
    <section className={pageClassName}>
      <div className={styles.pageHeader}>
        <div>
          <p className={styles.eyebrow}>Vista Cliente</p>
          <EntityHeader name={clienteName} status={clienteStatus} />
        </div>
        <PeriodSelector />
      </div>

      <ReportState report={reports.kpis} onRetry={refetch} emptyTitle="Sin KPIs del cliente">
        {() => <KpiStrip items={kpiItems} />}
      </ReportState>

      <div className={styles.contentStack.trim()}>
        <SectionHeader title="Contexto y tendencias" />
        <div className={styles.cardGrid}>
          <ChartCard title="Tendencia de comunicaciones" subtitle="Evolución mensual de llamadas, mensajes y minutos para el año seleccionado." span={2} actions={<TimeBadge label="Solo por año" />}>
            <ReportState report={reports.tendenciaComunicaciones} onRetry={refetch} emptyTitle="Sin tendencia disponible">
              {() => <YearBarChart data={tendenciaData} selectedYear={period.anio} height={300} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Costo por interacción" subtitle="Evolución mensual del costo unitario con promedio móvil.">
            <ReportState report={reports.costoPorInteraccion} onRetry={refetch} emptyTitle="Sin costo por interacción">
              {() => <LineAreaChart data={costoData} xKey="label" primaryLine="actual" referenceLine="reference" primaryLabel="Costo/interacción" referenceLabel="Promedio 3m" valueFormat="currency" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Uso vs capacidad contratada" subtitle="Consumo sobre la capacidad contratada del cliente.">
            <ReportState report={reports.usoVsCapacidad} onRetry={refetch} emptyTitle="Sin capacidad disponible">
              {() => usoCapacidadItems.length ? (
                <div className={styles.metricStack}>
                  {usoCapacidadItems.map((item) => (
                    <BulletChart key={item.id} actual={item.actual} target={item.target} label={item.label} unit={item.unit}
                      thresholdLabel={`Capacidad contratada: ${formatCompactNumber(item.target)}`}
                      showPercent height={104} />
                  ))}
                </div>
              ) : <EmptyState title="Sin capacidad visible" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Saturación horaria" subtitle="Carga por día y hora del tráfico del cliente.">
            <ReportState report={reports.saturacionHoraria} onRetry={refetch} emptyTitle="Sin saturación horaria disponible">
              {() => <HeatmapChart matrix={saturacionData.matrix} xLabels={saturacionData.xLabels} yLabels={saturacionData.yLabels} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Embudo de contacto por filial" subtitle="Intentos totales, logrados y fallidos. Selecciona la filial con el selector.">
            <ReportState report={reports.embudoContactoFilial} onRetry={refetch} emptyTitle="Sin datos de embudo">
              {() => <FilialFunnelChart data={embudoData} />}
            </ReportState>
          </ChartCard>
        </div>
      </div>

      <div className={styles.contentStack.trim()}>
        <SectionHeader title="Detalle granular" />
        <div className={styles.cardGrid}>
          <ChartCard title="Estado de pagos y mora" subtitle="Seguimiento por factura, pendiente y criticidad."
            actions={<div className={styles.inlineStats}><span>{pagosTable.rows.length} facturas</span></div>}>
            <ReportState report={reports.estadoPagos} onRetry={refetch} emptyTitle="Sin pagos disponibles">
              {() => <div className={styles.tablePreviewCompact}><DataTable columns={pagosTable.columns} rows={pagosTable.rows} pageSize={4} /></div>}
            </ReportState>
          </ChartCard>

          <ChartCard title="Grupos de colaboración" subtitle="Grupos con alta actividad y tasas de respuesta/entrega."
            actions={<div className={styles.inlineStats}><span>{gruposTable.rows.length} grupos</span></div>}>
            <ReportState report={reports.gruposColaboracion} onRetry={refetch} emptyTitle="Sin grupos de colaboración">
              {() => <div className={styles.tablePreviewCompact}><DataTable columns={gruposTable.columns} rows={gruposTable.rows} pageSize={4} /></div>}
            </ReportState>
          </ChartCard>

          <ChartCard title="Usuarios con mayor no contestación" subtitle="Usuarios con mayor caída de respuesta y carga operativa." span={2}>
            <ReportState report={reports.usuariosNoContestacion} onRetry={refetch} emptyTitle="Sin usuarios con no contestación">
              {() => (
                <div className={styles.contentStack}>
                  <BarComparisonChart data={usuariosChartData} primaryKey="primary" secondaryKey="secondary" labelKey="label" primaryLabel="Llamadas" secondaryLabel="No contestadas" valueFormat="number" />
                  <div className={styles.tablePreviewCompact}><DataTable columns={usuariosTable.columns} rows={usuariosTable.rows} pageSize={4} /></div>
                </div>
              )}
            </ReportState>
          </ChartCard>
        </div>
      </div>
    </section>
  );
}

export default ClienteDashboard;
