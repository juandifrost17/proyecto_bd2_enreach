package dashboard.controller;

import dashboard.dto.EnreachDashboardDTO;
import dashboard.dto.report.*;
import dashboard.service.EnreachDashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/dashboard/enreach")
@RequiredArgsConstructor
public class EnreachDashboardController {

    private final EnreachDashboardService enreachService;

    // KPIs combinados
    @GetMapping("/kpis")
    public ResponseEntity<EnreachDashboardDTO> getAllKpis(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        return ResponseEntity.ok(enreachService.getAllKpis(idEntidad, anio, periodo, tipoFiltro));
    }

    // Reportes contexto (4 params)
    @GetMapping("/reporte/1-facturado-vs-cobrado")
    public ResponseEntity<List<FacturadoVsCobradoPartnerDTO>> getReporte1(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<FacturadoVsCobradoPartnerDTO> data = enreachService.getReporte1FacturadoVsCobrado(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/reporte/3-riesgo-financiero")
    public ResponseEntity<List<RiesgoComercialDTO>> getReporte3(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<RiesgoComercialDTO> data = enreachService.getReporte3RiesgoFinanciero(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/reporte/4-demanda-horaria")
    public ResponseEntity<List<HeatmapDemandaEnreachDTO>> getReporte4(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<HeatmapDemandaEnreachDTO> data = enreachService.getReporte4DemandaHoraria(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/reporte/5-calidad-llamadas")
    public ResponseEntity<List<CalidadLlamadasDTO>> getReporte5(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<CalidadLlamadasDTO> data = enreachService.getReporte5CalidadLlamadas(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/reporte/6-salud-mensajeria")
    public ResponseEntity<List<SaludMensajeriaPartnerDTO>> getReporte6(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<SaludMensajeriaPartnerDTO> data = enreachService.getReporte6SaludMensajeria(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Tendencia facturación (2 params)
    @GetMapping("/reporte/tendencia-facturacion")
    public ResponseEntity<List<TendenciaFacturacionDTO>> getTendenciaFacturacion(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio) {
        List<TendenciaFacturacionDTO> data = enreachService.getTendenciaFacturacionAnual(idEntidad, anio);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Revenue por país (2 params)
    @GetMapping("/reporte/revenue-por-pais")
    public ResponseEntity<List<RevenuePorPaisDTO>> getRevenuePorPais(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio) {
        List<RevenuePorPaisDTO> data = enreachService.getRevenuePorPais(idEntidad, anio);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Scorecard (4 params)
    @GetMapping("/reporte/8-scorecard")
    public ResponseEntity<List<ScorecardEjecutivoDTO>> getReporte8(
            @RequestParam(required = false) Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<ScorecardEjecutivoDTO> data = enreachService.getReporte8Scorecard(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Vencimientos acuerdos (1 param)
    @GetMapping("/reporte/vencimientos-acuerdos")
    public ResponseEntity<List<VencimientoAcuerdoDTO>> getVencimientosAcuerdos(
            @RequestParam(required = false) Integer idEntidad) {
        List<VencimientoAcuerdoDTO> data = enreachService.getVencimientosAcuerdos(idEntidad);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Enreach Dashboard API is running");
    }
}
