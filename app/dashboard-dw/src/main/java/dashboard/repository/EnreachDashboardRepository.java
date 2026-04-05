package dashboard.repository;

import dashboard.dto.kpi.EnreachKpisDTO;
import dashboard.dto.report.*;
import dashboard.entity.QueryPlaceholder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;

import java.util.List;

@Repository
public interface EnreachDashboardRepository extends JpaRepository<QueryPlaceholder, Long> {

    // KPIs
    @Query(value = "SELECT * FROM fn_kpi_enreach_1_facturacion_total_partners(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EnreachKpisDTO> findKpiFacturacionTotal(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_enreach_2_cobro_total_partners(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EnreachKpisDTO> findKpiCobroTotal(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_enreach_3_saldo_pendiente_total(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EnreachKpisDTO> findKpiSaldoPendiente(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_enreach_4_partners_activos(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EnreachKpisDTO> findKpiPartnersActivos(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_enreach_5_tasa_global_contestacion(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EnreachKpisDTO> findKpiTasaContestacion(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_enreach_6_tasa_global_entrega_mensajes(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EnreachKpisDTO> findKpiTasaEntrega(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Reportes contexto
    @Query(value = "SELECT * FROM fn_reporte_1_facturado_vs_cobrado(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<FacturadoVsCobradoPartnerDTO> findReporte1FacturadoVsCobrado(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_3_riesgo_financiero(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<RiesgoComercialDTO> findReporte3RiesgoFinanciero(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_4_demanda_horaria_voz(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<HeatmapDemandaEnreachDTO> findReporte4DemandaHoraria(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_5_calidad_llamadas_partner(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<CalidadLlamadasDTO> findReporte5CalidadLlamadas(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_6_salud_mensajeria_partner(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<SaludMensajeriaPartnerDTO> findReporte6SaludMensajeria(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Tendencia — 2 params
    @Query(value = "SELECT * FROM fn_reporte_enreach_6_tendencia_facturacion_anual(:idEntidad, :anio)", nativeQuery = true)
    List<TendenciaFacturacionDTO> findTendenciaFacturacionAnual(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio);

    // Revenue por país — 2 params
    @Query(value = "SELECT * FROM fn_reporte_enreach_7_revenue_por_pais(:idEntidad, :anio)", nativeQuery = true)
    List<RevenuePorPaisDTO> findRevenuePorPais(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio);

    // Detalle granular
    @Query(value = "SELECT * FROM fn_reporte_8_scorecard_partners(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ScorecardEjecutivoDTO> findReporte8Scorecard(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Vencimientos acuerdos — 1 param
    @Query(value = "SELECT * FROM fn_reporte_enreach_9_vencimientos_acuerdos(:idEntidad)", nativeQuery = true)
    List<VencimientoAcuerdoDTO> findVencimientosAcuerdos(@Param("idEntidad") Integer idEntidad);
}
