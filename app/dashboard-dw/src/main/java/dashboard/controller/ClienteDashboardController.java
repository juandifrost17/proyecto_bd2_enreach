package dashboard.controller;

import dashboard.dto.ClienteDashboardDTO;
import dashboard.dto.report.*;
import dashboard.dto.search.ClienteSearchResultDTO;
import dashboard.service.ClienteDashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/dashboard/cliente")
@RequiredArgsConstructor
public class ClienteDashboardController {

    private final ClienteDashboardService clienteService;

    // KPIs combinados
    @GetMapping("/{id}/kpis")
    public ResponseEntity<ClienteDashboardDTO> getAllKpis(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        return ResponseEntity.ok(clienteService.getAllKpis(idEntidad, anio, periodo, tipoFiltro));
    }

    // CTX 1 — Tendencia comunicaciones (2 params)
    @GetMapping("/{id}/reporte/tendencia-comunicaciones")
    public ResponseEntity<List<TendenciaComunicacionesDTO>> getTendenciaComunicaciones(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio) {
        List<TendenciaComunicacionesDTO> data = clienteService.getTendenciaComunicaciones(idEntidad, anio);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // CTX 2 — Costo por interacción (4 params)
    @GetMapping("/{id}/reporte/costo-por-interaccion")
    public ResponseEntity<List<CostoPorInteraccionDTO>> getCostoPorInteraccion(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<CostoPorInteraccionDTO> data = clienteService.getCostoPorInteraccion(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // CTX 3 — Uso vs capacidad (4 params)
    @GetMapping("/{id}/reporte/20-uso-vs-capacidad")
    public ResponseEntity<List<UsoVsCapacidadDTO>> getReporte20(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<UsoVsCapacidadDTO> data = clienteService.getReporte20UsoVsCapacidad(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // CTX 4 — Saturación horaria (4 params)
    @GetMapping("/{id}/reporte/21-saturacion-horaria")
    public ResponseEntity<List<HeatmapDemandaClienteDTO>> getReporte21(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<HeatmapDemandaClienteDTO> data = clienteService.getReporte21SaturacionHoraria(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // CTX 5 — Embudo contacto filial (4 params)
    @GetMapping("/{id}/reporte/embudo-contacto-filial")
    public ResponseEntity<List<EmbudoContactoFilialDTO>> getEmbudoContactoFilial(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<EmbudoContactoFilialDTO> data = clienteService.getEmbudoContactoFilial(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // DET 6 — Estado pagos (4 params)
    @GetMapping("/{id}/reporte/19-estado-pagos")
    public ResponseEntity<List<EstadoPagosDTO>> getReporte19(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<EstadoPagosDTO> data = clienteService.getReporte19EstadoPagos(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // DET 8 — Usuarios no contestación (4 params)
    @GetMapping("/{id}/reporte/22-usuarios-no-contestacion")
    public ResponseEntity<List<UsuariosNoContestacionDTO>> getReporte22(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<UsuariosNoContestacionDTO> data = clienteService.getReporte22UsuariosNoContestacion(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // DET 9 — Grupos colaboración (4 params)
    @GetMapping("/{id}/reporte/grupos-colaboracion")
    public ResponseEntity<List<GruposColaboracionDTO>> getGruposColaboracion(
            @PathVariable("id") Integer idEntidad,
            @RequestParam(defaultValue = "2025") Integer anio,
            @RequestParam(defaultValue = "1") Integer periodo,
            @RequestParam(defaultValue = "M") String tipoFiltro) {
        List<GruposColaboracionDTO> data = clienteService.getGruposColaboracion(idEntidad, anio, periodo, tipoFiltro);
        return data.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(data);
    }

    // All clientes — used by the entity dropdown selector
    @GetMapping("/all")
    public ResponseEntity<List<ClienteSearchResultDTO>> getAllClientes() {
        return ResponseEntity.ok(clienteService.getAllClientes());
    }

    // Search
    @GetMapping("/search")
    public ResponseEntity<List<ClienteSearchResultDTO>> searchClientes(@RequestParam String query) {
        try {
            List<ClienteSearchResultDTO> results = clienteService.searchClientes(query);
            return ResponseEntity.ok(results);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Info by ID — resolves name and estado for direct URL navigation
    @GetMapping("/{id}/info")
    public ResponseEntity<ClienteSearchResultDTO> getClienteInfo(@PathVariable Integer id) {
        return clienteService.getClienteInfo(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Cliente Dashboard API is running");
    }
}
