package dashboard.controller;

import dashboard.dto.PartnerDashboardDTO;
import dashboard.dto.report.*;
import dashboard.dto.search.PartnerSearchResultDTO;
import dashboard.service.PartnerDashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/dashboard/partner")
@RequiredArgsConstructor
public class PartnerDashboardController {

    private final PartnerDashboardService partnerService;

    // KPIs combinados
    @GetMapping("/{id}/kpis")
    public ResponseEntity<PartnerDashboardDTO> getAllKpis(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        return ResponseEntity.ok(partnerService.getAllKpis(idEntidad, anio, periodo, tipoFiltro));
    }

    // Reportes contexto (4 params)
    @GetMapping("/{id}/reporte/9-facturado-vs-cobrado")
    public ResponseEntity<List<FacturadoVsCobradoClienteDTO>> getReporte9(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<FacturadoVsCobradoClienteDTO> data = partnerService.getReporte9FacturadoVsCobrado(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/{id}/reporte/10-aging-cartera")
    public ResponseEntity<List<AgingCarteraDTO>> getReporte10(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<AgingCarteraDTO> data = partnerService.getReporte10AgingCartera(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/{id}/reporte/11-uso-vs-plan")
    public ResponseEntity<List<UsoVsPlanPartnerDTO>> getReporte11(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<UsoVsPlanPartnerDTO> data = partnerService.getReporte11UsoVsPlan(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/{id}/reporte/14-deterioro-llamadas")
    public ResponseEntity<List<DeterioroLlamadasDTO>> getReporte14(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<DeterioroLlamadasDTO> data = partnerService.getReporte14DeterioroLlamadas(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    @GetMapping("/{id}/reporte/15-calidad-mensajeria")
    public ResponseEntity<List<CalidadMensajeriaClienteDTO>> getReporte15(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<CalidadMensajeriaClienteDTO> data = partnerService.getReporte15CalidadMensajeria(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Tendencia — crecimiento neto clientes (2 params)
    @GetMapping("/{id}/reporte/crecimiento-neto-clientes")
    public ResponseEntity<List<CrecimientoNetoClientesDTO>> getCrecimientoNeto(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio) {
        List<CrecimientoNetoClientesDTO> data = partnerService.getCrecimientoNetoClientes(idEntidad, anio);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Detalle granular
    @GetMapping("/{id}/reporte/16-mesa-operativa")
    public ResponseEntity<List<MesaOperativaDTO>> getReporte16(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<MesaOperativaDTO> data = partnerService.getReporte16MesaOperativa(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // Vencimientos contratos (1 param)
    @GetMapping("/{id}/reporte/vencimientos-contratos")
    public ResponseEntity<List<VencimientoContratoDTO>> getVencimientosContratos(
            @PathVariable("id") Integer idEntidad) {
        List<VencimientoContratoDTO> data = partnerService.getVencimientosContratos(idEntidad);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // All partners — used by the entity dropdown selector
    @GetMapping("/all")
    public ResponseEntity<List<PartnerSearchResultDTO>> getAllPartners() {
        return ResponseEntity.ok(partnerService.getAllPartners());
    }

    // Search
    @GetMapping("/search")
    public ResponseEntity<List<PartnerSearchResultDTO>> searchPartners(@RequestParam String query) {
        try {
            List<PartnerSearchResultDTO> results = partnerService.searchPartners(query);
            return ResponseEntity.ok(results);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Info by ID — resolves name and estado for direct URL navigation
    @GetMapping("/{id}/info")
    public ResponseEntity<PartnerSearchResultDTO> getPartnerInfo(@PathVariable Integer id) {
        return partnerService.getPartnerInfo(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Partner Dashboard API is running");
    }
}
