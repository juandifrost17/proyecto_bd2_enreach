package dashboard.service;

import dashboard.dto.ClienteDashboardDTO;
import dashboard.dto.kpi.ClienteKpisDTO;
import dashboard.dto.report.*;
import dashboard.dto.search.ClienteSearchResultDTO;
import dashboard.repository.ClienteDashboardRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClienteDashboardService {

    private final ClienteDashboardRepository clienteRepository;

    // KPIs individuales
    public Optional<ClienteKpisDTO> getGastoPeriodo(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(clienteRepository.findKpiGastoPeriodo(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<ClienteKpisDTO> getMontoPagado(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(clienteRepository.findKpiMontoPagado(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<ClienteKpisDTO> getSaldoPendiente(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(clienteRepository.findKpiSaldoPendiente(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<ClienteKpisDTO> getUsoMinutos(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(clienteRepository.findKpiUsoMinutos(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<ClienteKpisDTO> getUsoMensajes(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(clienteRepository.findKpiUsoMensajes(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<ClienteKpisDTO> getColasFueraSla(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(clienteRepository.findKpiColasFueraSla(idEntidad, anio, periodo, tipoFiltro));
    }

    // KPIs combinados
    public ClienteDashboardDTO getAllKpis(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        log.info("Cargando todos los KPIs de Cliente - Entity: {}, Period: {}/{}/{}", idEntidad, anio, periodo, tipoFiltro);
        var kpi1 = firstOf(clienteRepository.findKpiGastoPeriodo(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi2 = firstOf(clienteRepository.findKpiMontoPagado(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi3 = firstOf(clienteRepository.findKpiSaldoPendiente(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi4 = firstOf(clienteRepository.findKpiUsoMinutos(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi5 = firstOf(clienteRepository.findKpiUsoMensajes(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi6 = firstOf(clienteRepository.findKpiColasFueraSla(idEntidad, anio, periodo, tipoFiltro)).orElse(null);

        return ClienteDashboardDTO.builder()
                .totalGasto(kpi1 != null ? kpi1.getTotalGasto() : null)
                .totalPagado(kpi2 != null ? kpi2.getTotalPagado() : null)
                .saldoPendiente(kpi3 != null ? kpi3.getSaldoPendiente() : null)
                .totalMinutos(kpi4 != null ? kpi4.getTotalMinutos() : null)
                .totalMensajes(kpi5 != null ? kpi5.getTotalMensajes() : null)
                .colasFueraSLA(kpi6 != null ? kpi6.getColasFueraSLA() : null)
                .build();
    }

    // Reportes contexto
    public List<TendenciaComunicacionesDTO> getTendenciaComunicaciones(Integer idEntidad, Integer anio) {
        return clienteRepository.findTendenciaComunicaciones(idEntidad, anio);
    }

    public List<CostoPorInteraccionDTO> getCostoPorInteraccion(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findCostoPorInteraccion(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<UsoVsCapacidadDTO> getReporte20UsoVsCapacidad(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findReporte20UsoVsCapacidad(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<HeatmapDemandaClienteDTO> getReporte21SaturacionHoraria(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findReporte21SaturacionHoraria(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<EmbudoContactoFilialDTO> getEmbudoContactoFilial(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findEmbudoContactoFilial(idEntidad, anio, periodo, tipoFiltro);
    }

    // Detalle granular
    public List<EstadoPagosDTO> getReporte19EstadoPagos(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findReporte19EstadoPagos(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<UsuariosNoContestacionDTO> getReporte22UsuariosNoContestacion(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findReporte22UsuariosNoContestacion(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<GruposColaboracionDTO> getGruposColaboracion(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return clienteRepository.findGruposColaboracion(idEntidad, anio, periodo, tipoFiltro);
    }

    // Search (accepts empty string → SQL returns all via ILIKE '%%')
    public List<ClienteSearchResultDTO> searchClientes(String query) {
        return clienteRepository.searchClientes(query == null ? "" : query.trim());
    }

    // All clientes — used by the dropdown selector (no LIMIT, returns all)
    public List<ClienteSearchResultDTO> getAllClientes() {
        return clienteRepository.findAllClientes();
    }

    // Info by ID — resolves name/estado without needing the search endpoint
    public Optional<ClienteSearchResultDTO> getClienteInfo(Integer id) {
        List<ClienteSearchResultDTO> results = clienteRepository.findClienteById(id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    private <T> Optional<T> firstOf(List<T> list) {
        return (list == null || list.isEmpty()) ? Optional.empty() : Optional.of(list.get(0));
    }
}
