import { useMemo } from 'react';
import { BellRing, CircleDollarSign, MessageSquareText, PhoneCall, Users, Wallet } from 'lucide-react';
import { useOutletContext } from 'react-router-dom';
import PeriodSelector from '@/components/filters/PeriodSelector';
import ChartCard from '@/components/cards/ChartCard';
import SectionHeader from '@/components/cards/SectionHeader';
import BarComparisonChart from '@/components/charts/BarComparisonChart';
import DonutChart from '@/components/charts/DonutChart';
import HeatmapChart from '@/components/charts/HeatmapChart';
import RiskBarChart from '@/components/charts/RiskBarChart';
import PartnerYearChart from '@/components/charts/PartnerYearChart';
import StackedBarChart from '@/components/charts/StackedBarChart';
import ReportState from '@/components/feedback/ReportState';
import KpiStrip from '@/components/kpis/KpiStrip';
import DataTable from '@/components/tables/DataTable';
import TimeBadge from '@/components/status/TimeBadge';
import { usePeriod } from '@/context/PeriodContext';
import {
  mapCalidadLlamadasDonut,
  mapFacturadoVsCobrado,
  mapHeatmapData,
  mapRevenuePorPaisData,
  mapRiesgoFinancieroData,
  mapSaludMensajeriaData,
  mapTendenciaFacturacionData,
  getTendenciaFacturacionCategories,
  getSaludMensajeriaCategories,
} from '@/mappers/chart.mappers';
import { mapEnreachKpis } from '@/mappers/kpi.mappers';
import { mapScorecardTable, mapVencimientosAcuerdosTable } from '@/mappers/table.mappers';
import { useEnreachDashboardReports } from '@/hooks/useDashboardReports';
import styles from './DashboardPage.module.css';

const KPI_ICON_BY_ID = {
  totalFacturado: Wallet, totalCobrado: CircleDollarSign, saldoPendiente: BellRing,
  partnersActivos: Users, tasaContestacion: PhoneCall, tasaEntrega: MessageSquareText,
};

function buildKpiItems(dto) {
  return mapEnreachKpis(dto).map((item) => ({ ...item, icon: KPI_ICON_BY_ID[item.id] }));
}

function EnreachDashboard() {
  const { audience } = useOutletContext();
  const period = usePeriod();
  const { reports, refetch } = useEnreachDashboardReports(period);

  const kpiItems = useMemo(() => buildKpiItems(reports.kpis?.rawData ?? {}), [reports.kpis?.rawData]);
  const facturadoData = useMemo(() => mapFacturadoVsCobrado(reports.facturadoVsCobrado?.rawData ?? []), [reports.facturadoVsCobrado?.rawData]);
  const riskRows = useMemo(() => mapRiesgoFinancieroData(reports.riesgoFinanciero?.rawData ?? []), [reports.riesgoFinanciero?.rawData]);
  const heatmapData = useMemo(() => mapHeatmapData(reports.demandaHoraria?.rawData ?? []), [reports.demandaHoraria?.rawData]);
  const donutData = useMemo(() => mapCalidadLlamadasDonut(reports.calidadLlamadas?.rawData ?? []), [reports.calidadLlamadas?.rawData]);
  const mensajeriaData = useMemo(() => mapSaludMensajeriaData(reports.saludMensajeria?.rawData ?? []), [reports.saludMensajeria?.rawData]);
  const tendenciaData = useMemo(() => mapTendenciaFacturacionData(reports.tendenciaFacturacion?.rawData ?? []), [reports.tendenciaFacturacion?.rawData]);
  const tendenciaCats = useMemo(() => getTendenciaFacturacionCategories(reports.tendenciaFacturacion?.rawData ?? []), [reports.tendenciaFacturacion?.rawData]);
  const revenuePaisData = useMemo(() => mapRevenuePorPaisData(reports.revenuePorPais?.rawData ?? []), [reports.revenuePorPais?.rawData]);
  const scorecard = useMemo(() => mapScorecardTable(reports.scorecard?.rawData ?? []), [reports.scorecard?.rawData]);
  const vencimientos = useMemo(() => mapVencimientosAcuerdosTable(reports.vencimientosAcuerdos?.rawData ?? []), [reports.vencimientosAcuerdos?.rawData]);

  const pageClassName = styles.page;

  return (
    <section className={pageClassName}>
      <div className={styles.pageHeader}>
        <div className={styles.headerCopy}>
          <p className={styles.eyebrow}>Vista Enreach</p>
          <h1 className={styles.title}>Dashboard ejecutivo</h1>
          <p className={styles.description}>Lectura consolidada de facturación, cobranza, calidad de voz y salud de mensajería a nivel plataforma.</p>
        </div>
        <PeriodSelector />
      </div>

      <ReportState report={reports.kpis} onRetry={refetch} emptyTitle="Sin KPIs disponibles">
        {() => <KpiStrip items={kpiItems} />}
      </ReportState>

      <div className={styles.contentStack.trim()}>
        <SectionHeader title="Contexto y tendencias" />
        <div className={styles.cardGrid}>
          <ChartCard title="Facturado vs cobrado" subtitle="Comparación ejecutiva por partner." span={2}>
            <ReportState report={reports.facturadoVsCobrado} onRetry={refetch} emptyTitle="Sin comparativo disponible">
              {() => <BarComparisonChart data={facturadoData} primaryKey="facturado" secondaryKey="cobrado" labelKey="label" primaryLabel="Facturado" secondaryLabel="Cobrado" valueFormat="currency" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Tendencia facturación anual" subtitle="Facturación por partner para el año seleccionado." span={2} actions={<TimeBadge label="Solo por año" />}>
            <ReportState report={reports.tendenciaFacturacion} onRetry={refetch} emptyTitle="Sin tendencia disponible">
              {() => <PartnerYearChart data={tendenciaData} categories={tendenciaCats} selectedYear={period.anio} height={340} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Riesgo financiero" subtitle="Priorización por exposición comercial pendiente.">
            <ReportState report={reports.riesgoFinanciero} onRetry={refetch} emptyTitle="Sin partners en riesgo">
              {() => <RiskBarChart data={riskRows} valueKey="value" riskKey="risk" labelKey="label" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Revenue por país" subtitle="Distribución geográfica de facturación." actions={<TimeBadge label="Solo por año" />}>
            <ReportState report={reports.revenuePorPais} onRetry={refetch} emptyTitle="Sin datos por país">
              {() => <BarComparisonChart data={revenuePaisData} primaryKey="facturado" secondaryKey="pendiente" labelKey="label" primaryLabel="Facturado" secondaryLabel="Pendiente" valueFormat="currency" />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Demanda horaria voz" subtitle="Picos semanales para coordinación de capacidad.">
            <ReportState report={reports.demandaHoraria} onRetry={refetch} emptyTitle="Sin demanda horaria disponible">
              {() => <HeatmapChart matrix={heatmapData.matrix} xLabels={heatmapData.xLabels} yLabels={heatmapData.yLabels} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Contestación de llamadas" subtitle="Proporción global de llamadas contestadas vs no contestadas.">
            <ReportState report={reports.calidadLlamadas} onRetry={refetch} emptyTitle="Sin calidad de voz disponible">
              {() => <DonutChart contestadas={donutData.contestadas} noContestadas={donutData.noContestadas} />}
            </ReportState>
          </ChartCard>

          <ChartCard title="Salud mensajería" subtitle="Mix operativo de entregas y mensajes no entregados." span={2}>
            <ReportState report={reports.saludMensajeria} onRetry={refetch} emptyTitle="Sin salud de mensajería disponible">
              {() => <StackedBarChart data={mensajeriaData} categories={getSaludMensajeriaCategories()} labelKey="label" height={320} />}
            </ReportState>
          </ChartCard>
        </div>
      </div>

      <div className={styles.contentStack.trim()}>
        <SectionHeader title="Detalle granular" />
        <div className={styles.cardGrid}>
          <ChartCard title="Scorecard operativo" subtitle="Seguimiento ejecutivo consolidado." actions={<div className={styles.inlineStats}><span>{scorecard.rows.length} partners</span></div>}>
            <ReportState report={reports.scorecard} onRetry={refetch} emptyTitle="Sin scorecard disponible">
              {() => <div className={styles.tablePreview}><DataTable columns={scorecard.columns} rows={scorecard.rows} pageSize={5} /></div>}
            </ReportState>
          </ChartCard>

          <ChartCard title="Vencimientos de acuerdos" subtitle="Contratos próximos a vencer por partner." actions={<div style={{display:"flex",alignItems:"center",gap:"0.5rem"}}><TimeBadge label="Sin filtro de tiempo" /><span className={styles.inlineStats}>{vencimientos.rows.length} acuerdos</span></div>}>
            <ReportState report={reports.vencimientosAcuerdos} onRetry={refetch} emptyTitle="Sin vencimientos">
              {() => <div className={styles.tablePreview}><DataTable columns={vencimientos.columns} rows={vencimientos.rows} pageSize={5} /></div>}
            </ReportState>
          </ChartCard>
        </div>
      </div>
    </section>
  );
}

export default EnreachDashboard;
