package dashboard.repository;

import dashboard.dto.kpi.PartnerKpisDTO;
import dashboard.dto.report.*;
import dashboard.dto.search.PartnerSearchResultDTO;
import dashboard.entity.QueryPlaceholder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;

import java.util.List;

@Repository
public interface PartnerDashboardRepository extends JpaRepository<QueryPlaceholder, Long> {

    // KPIs
    @Query(value = "SELECT * FROM fn_kpi_partner_1_facturacion_periodo(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<PartnerKpisDTO> findKpiFacturacionPeriodo(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_partner_2_cobro_periodo(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<PartnerKpisDTO> findKpiCobroPeriodo(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_partner_3_cartera_vencida(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<PartnerKpisDTO> findKpiCarteraVencida(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_partner_4_clientes_activos(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<PartnerKpisDTO> findKpiClientesActivos(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_partner_5_uso_promedio_plan(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<PartnerKpisDTO> findKpiUsoPromedioPlan(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_partner_6_tasa_entrega_mensajes(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<PartnerKpisDTO> findKpiTasaEntregaMensajes(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Reportes contexto
    @Query(value = "SELECT * FROM fn_reporte_9_facturado_cobrado_cliente(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<FacturadoVsCobradoClienteDTO> findReporte9FacturadoVsCobrado(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_10_aging_cartera_cliente(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<AgingCarteraDTO> findReporte10AgingCartera(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_11_uso_real_vs_plan(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<UsoVsPlanPartnerDTO> findReporte11UsoVsPlan(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_14_deterioro_llamadas(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<DeterioroLlamadasDTO> findReporte14DeterioroLlamadas(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_reporte_15_calidad_mensajeria_cliente(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<CalidadMensajeriaClienteDTO> findReporte15CalidadMensajeria(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Tendencia — crecimiento neto clientes — 2 params
    @Query(value = "SELECT * FROM fn_reporte_partner_8_crecimiento_neto_clientes(:idEntidad, :anio)", nativeQuery = true)
    List<CrecimientoNetoClientesDTO> findCrecimientoNetoClientes(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio);

    // Detalle granular
    @Query(value = "SELECT * FROM fn_reporte_16_mesa_operativa_clientes(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<MesaOperativaDTO> findReporte16MesaOperativa(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Vencimientos contratos — 1 param
    @Query(value = "SELECT * FROM fn_reporte_partner_12_vencimientos_contratos(:idEntidad)", nativeQuery = true)
    List<VencimientoContratoDTO> findVencimientosContratos(@Param("idEntidad") Integer idEntidad);

    // Search
    @Query(value = "SELECT * FROM fn_search_partners(:query)", nativeQuery = true)
    List<PartnerSearchResultDTO> searchPartners(@Param("query") String query);

    // Lookup by ID for direct URL navigation
    @Query(value = "SELECT dp.id_partner AS id, dp.nombre_partner AS nombre, dp.estado_partner AS estado FROM dim_partner dp WHERE dp.id_partner = :id LIMIT 1", nativeQuery = true)
    List<PartnerSearchResultDTO> findPartnerById(@Param("id") Integer id);
}
