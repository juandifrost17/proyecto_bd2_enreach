import { useMemo } from 'react';
import { BarChart3, BellRing, CircleDollarSign, MessageSquareText, Users, Wallet } from 'lucide-react';
import { useOutletContext, useParams } from 'react-router-dom';
import ChartCard from '@/components/cards/ChartCard';
import SectionHeader from '@/components/cards/SectionHeader';
import BulletChart from '@/components/charts/BulletChart';
import BarComparisonChart from '@/components/charts/BarComparisonChart';
import AgingCarteraChart from '@/components/charts/AgingCarteraChart';
import DeterioroLlamadasChart from '@/components/charts/DeterioroLlamadasChart';
import NetGrowthChart from '@/components/charts/NetGrowthChart';
import StackedBarChart from '@/components/charts/StackedBarChart';
import EntityHeader from '@/components/filters/EntityHeader';
import PeriodSelector from '@/components/filters/PeriodSelector';
import EmptyState from '@/components/feedback/EmptyState';
import ReportState from '@/components/feedback/ReportState';
import KpiStrip from '@/components/kpis/KpiStrip';
import DataTable from '@/components/tables/DataTable';
import TimeBadge from '@/components/status/TimeBadge';
import { usePeriod } from '@/context/PeriodContext';
import {
  getSaludMensajeriaCategories,
  mapAgingCarteraData,
  mapCrecimientoNetoData,
  mapDeterioroLlamadasData,
  mapFacturadoVsCobrado,
  mapPartnerUsoVsPlanBullets,
  mapSaludMensajeriaData,
} from '@/mappers/chart.mappers';
import { mapPartnerKpis } from '@/mappers/kpi.mappers';
import { mapMesaOperativaTable, mapVencimientosContratosTable } from '@/mappers/table.mappers';
import { usePartnerDashboardReports } from '@/hooks/useDashboardReports';
import useEntityName from '@/hooks/useEntityName';
import { formatPercent } from '@/utils/formatters';
import styles from './DashboardPage.module.css';

const KPI_ICON_BY_ID = {
  facturacionPeriodo: Wallet, cobroPeriodo: CircleDollarSign, carteraVencida: BellRing,
  clientesActivos: Users, usoPromedioPlan: BarChart3, tasaEntrega: MessageSquareText,
};

function buildPartnerKpiItems(dto) {
  return mapPartnerKpis(dto).map((item) => ({ ...item, icon: KPI_ICON_BY_ID[item.id] }));
}

function PartnerDashboard() {
  const { id } = useParams();
  const { audience } = useOutletContext();
  const period = usePeriod();
  const { reports, refetch } = usePartnerDashboardReports(id, period);
  const { name: partnerName, status: partnerStatus } = useEntityName('partner', id, '');

  const kpiItems = useMemo(() => buildPartnerKpiItems(reports.kpis?.rawData ?? {}), [reports.kpis?.rawData]);
  const facturadoData = useMemo(() => mapFacturadoVsCobrado(reports.facturadoVsCobrado?.rawData ?? []), [reports.facturadoVsCobrado?.rawData]);
  const agingData = useMemo(() => mapAgingCarteraData(reports.agingCartera?.rawData ?? []), [reports.agingCartera?.rawData]);
  const usoBullets = useMemo(() => mapPartnerUsoVsPlanBullets(reports.usoVsPlan?.rawData ?? []), [reports.usoVsPlan?.rawData]);
  const deterioroData = useMemo(() => mapDeterioroLlamadasData(reports.deterioroLlamadas?.rawData ?? []), [reports.deterioroLlamadas?.rawData]);
  const mensajeriaData = useMemo(() => mapSaludMensajeriaData(reports.calidadMensajeria?.rawData ?? []), [reports.calidadMensajeria?.rawData]);
  const crecimientoData = useMemo(() => mapCrecimientoNetoData(reports.crecimientoNeto?.rawData ?? []), [reports.crecimientoNeto?.rawData]);
  const mesaOperativa = useMemo(() => mapMesaOperativaTable(reports.mesaOperativa?.rawData ?? []), [reports.mesaOperativa?.rawData]);
  const vencimientosContratos = useMemo(() => mapVencimientosContratosTable(reports.vencimientosContratos?.rawData ?? []), [reports.vencimientosContratos?.rawData]);

  const pageClassName = styles.page;

  return (
    <section className={pageClassName}>
      <div className={styles.pageHeader}>
        <div>
          <p className={styles.eyebrow}>Vista Partner</p>
          <EntityHeader name={partnerName} status={partnerStatus} />
        </div>
        <PeriodSelector />
      </div>

      <ReportState report={reports.kpis} onRetry={refetch} emptyTitle="Sin KPIs del partner">
        {() => <KpiStrip items={kpiItems} />}
      </ReportState>

      <div className={styles.contentStack.trim()}>
        <SectionHeader title="Contexto y tendencias" />
        <div className={styles.cardGrid}>
          <ChartCard title="Facturado vs cobrado por cliente" subtitle="Clientes con mayor impacto en el partner." span={2}>
            <ReportState report={reports.facturadoVsCobrado} onRetry={refetch} emptyTitle="Sin comparativo disponible">
              {() => <BarComparisonChart data={facturadoData} primaryKey="facturado" secondaryKey="cobrado" labelKey="label" primaryLabel="Facturado" secondaryLabel="Cobrado" valueFormat="currency" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Aging de cartera" subtitle="Saldo pendiente por cliente, segmentado por antigüedad de mora.">
            <ReportState report={reports.agingCartera} onRetry={refetch} emptyTitle="Sin aging de cartera disponible">
              {() => <AgingCarteraChart data={agingData} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Uso real vs plan" subtitle="Clientes con mayor presión sobre la capacidad contratada.">
            <ReportState report={reports.usoVsPlan} onRetry={refetch} emptyTitle="Sin uso vs plan disponible">
              {() => usoBullets.length ? (
                <div className={styles.metricStack}>
                  {usoBullets.map((item) => (
                    <BulletChart key={item.id} actual={item.actual} target={item.target} label={item.label} unit="percent"
                      thresholdLabel={`Min ${formatPercent(item.minutosPct)} · Msg ${formatPercent(item.mensajesPct)}`} />
                  ))}
                </div>
              ) : <EmptyState title="Sin capacidad visible" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Crecimiento neto de clientes" subtitle="Altas vs bajas por trimestre en los últimos 2 años." actions={<TimeBadge label="Solo por año" />}>
            <ReportState report={reports.crecimientoNeto} onRetry={refetch} emptyTitle="Sin datos de crecimiento">
              {() => <NetGrowthChart data={crecimientoData} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Deterioro de llamadas" subtitle="Volumen total de llamadas y % tasa de pérdida vs período anterior, por cliente.">
            <ReportState report={reports.deterioroLlamadas} onRetry={refetch} emptyTitle="Sin deterioro de llamadas disponible">
              {() => <DeterioroLlamadasChart data={deterioroData} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Calidad de mensajería" subtitle="Entregas y mensajes no entregados a nivel cliente." span={2}>
            <ReportState report={reports.calidadMensajeria} onRetry={refetch} emptyTitle="Sin salud de mensajería disponible">
              {() => <StackedBarChart data={mensajeriaData} categories={getSaludMensajeriaCategories()} labelKey="label" height={320} />}
            </ReportState>
          </ChartCard>
        </div>
      </div>

      <div className={styles.contentStack.trim()}>
        <SectionHeader title="Detalle granular" />
        <div className={styles.cardGrid}>
          <ChartCard title="Mesa operativa de clientes" subtitle="Seguimiento diario para cartera, uso y cola crítica." span={2}
            actions={<div className={styles.inlineStats}><span>{mesaOperativa.rows.length} clientes</span></div>}>
            <ReportState report={reports.mesaOperativa} onRetry={refetch} emptyTitle="Sin mesa operativa disponible">
              {() => <div className={styles.tablePreview}><DataTable columns={mesaOperativa.columns} rows={mesaOperativa.rows} pageSize={6} /></div>}
            </ReportState>
          </ChartCard>

          <ChartCard title="Vencimientos de contratos" subtitle="Contratos próximos a vencer del portfolio." span={2} actions={<div className={styles.inlineStats}><span>{vencimientosContratos.rows.length} contratos</span></div>}>
            <ReportState report={reports.vencimientosContratos} onRetry={refetch} emptyTitle="Sin vencimientos">
              {() => <div className={styles.tablePreview}><DataTable columns={vencimientosContratos.columns} rows={vencimientosContratos.rows} pageSize={6} /></div>}
            </ReportState>
          </ChartCard>
        </div>
      </div>
    </section>
  );
}

export default PartnerDashboard;
