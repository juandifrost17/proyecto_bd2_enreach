package dashboard.repository;

import dashboard.dto.kpi.ClienteKpisDTO;
import dashboard.dto.report.*;
import dashboard.dto.search.ClienteSearchResultDTO;
import dashboard.entity.QueryPlaceholder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;

import java.util.List;

@Repository
public interface ClienteDashboardRepository extends JpaRepository<QueryPlaceholder, Long> {

    // KPIs
    @Query(value = "SELECT * FROM fn_kpi_cliente_1_gasto_periodo(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ClienteKpisDTO> findKpiGastoPeriodo(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_cliente_2_monto_pagado(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ClienteKpisDTO> findKpiMontoPagado(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_cliente_3_saldo_pendiente(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ClienteKpisDTO> findKpiSaldoPendiente(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_cliente_4_uso_minutos(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ClienteKpisDTO> findKpiUsoMinutos(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_cliente_5_uso_mensajes(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ClienteKpisDTO> findKpiUsoMensajes(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    @Query(value = "SELECT * FROM fn_kpi_cliente_6_colas_fuera_sla(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<ClienteKpisDTO> findKpiColasFueraSla(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // CTX 1 — Tendencia comunicaciones — 2 params
    @Query(value = "SELECT * FROM fn_reporte_cliente_1_tendencia_comunicaciones(:idEntidad, :anio)", nativeQuery = true)
    List<TendenciaComunicacionesDTO> findTendenciaComunicaciones(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio);

    // CTX 2 — Costo por interacción
    @Query(value = "SELECT * FROM fn_reporte_cliente_2_costo_por_interaccion(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<CostoPorInteraccionDTO> findCostoPorInteraccion(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // CTX 3 — Uso vs capacidad
    @Query(value = "SELECT * FROM fn_reporte_20_uso_vs_capacidad(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<UsoVsCapacidadDTO> findReporte20UsoVsCapacidad(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // CTX 4 — Saturación horaria
    @Query(value = "SELECT * FROM fn_reporte_21_saturacion_horaria(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<HeatmapDemandaClienteDTO> findReporte21SaturacionHoraria(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // CTX 5 — Embudo contacto filial
    @Query(value = "SELECT * FROM fn_reporte_cliente_5_embudo_contacto_filial(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EmbudoContactoFilialDTO> findEmbudoContactoFilial(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // DET 6 — Estado pagos
    @Query(value = "SELECT * FROM fn_reporte_19_estado_pagos_facturas(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<EstadoPagosDTO> findReporte19EstadoPagos(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // DET 7 — Usuarios no contestación
    @Query(value = "SELECT * FROM fn_reporte_22_usuarios_no_contestacion(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<UsuariosNoContestacionDTO> findReporte22UsuariosNoContestacion(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // DET 8 — Grupos colaboración
    @Query(value = "SELECT * FROM fn_reporte_cliente_9_grupos_colaboracion(:idEntidad, :anio, :periodo, :tipoFiltro)", nativeQuery = true)
    List<GruposColaboracionDTO> findGruposColaboracion(@Param("idEntidad") Integer idEntidad, @Param("anio") Integer anio, @Param("periodo") Integer periodo, @Param("tipoFiltro") String tipoFiltro);

    // Search (limited to 20 for autocomplete)
    @Query(value = "SELECT * FROM fn_search_clientes(:query)", nativeQuery = true)
    List<ClienteSearchResultDTO> searchClientes(@Param("query") String query);

    // Lookup by ID for direct URL navigation
    @Query(value = "SELECT DISTINCT dc.id_cliente AS id, dc.razon_social AS nombre, dc.estado_cliente AS estado FROM dim_cliente dc WHERE dc.id_cliente = :id LIMIT 1", nativeQuery = true)
    List<ClienteSearchResultDTO> findClienteById(@Param("id") Integer id);

    // All clientes without limit — used by the dropdown selector
    @Query(value = "SELECT DISTINCT ON (dc.id_cliente) dc.id_cliente AS id, dc.razon_social AS nombre, dc.estado_cliente AS estado FROM dim_cliente dc ORDER BY dc.id_cliente, dc.razon_social", nativeQuery = true)
    List<ClienteSearchResultDTO> findAllClientes();
}
