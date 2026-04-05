package dashboard.service;

import dashboard.dto.PartnerDashboardDTO;
import dashboard.dto.kpi.PartnerKpisDTO;
import dashboard.dto.report.*;
import dashboard.dto.search.PartnerSearchResultDTO;
import dashboard.repository.PartnerDashboardRepository;
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
public class PartnerDashboardService {

    private final PartnerDashboardRepository partnerRepository;

    // KPIs individuales
    public Optional<PartnerKpisDTO> getFacturacionPeriodo(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(partnerRepository.findKpiFacturacionPeriodo(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<PartnerKpisDTO> getCobroPeriodo(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(partnerRepository.findKpiCobroPeriodo(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<PartnerKpisDTO> getCarteraVencida(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(partnerRepository.findKpiCarteraVencida(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<PartnerKpisDTO> getClientesActivos(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(partnerRepository.findKpiClientesActivos(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<PartnerKpisDTO> getUsoPromedioPlan(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(partnerRepository.findKpiUsoPromedioPlan(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<PartnerKpisDTO> getTasaEntregaMensajes(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(partnerRepository.findKpiTasaEntregaMensajes(idEntidad, anio, periodo, tipoFiltro));
    }

    // KPIs combinados
    public PartnerDashboardDTO getAllKpis(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        log.info("Cargando todos los KPIs de Partner - Entity: {}, Period: {}/{}/{}", idEntidad, anio, periodo, tipoFiltro);
        var kpi1 = firstOf(partnerRepository.findKpiFacturacionPeriodo(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi2 = firstOf(partnerRepository.findKpiCobroPeriodo(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi3 = firstOf(partnerRepository.findKpiCarteraVencida(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi4 = firstOf(partnerRepository.findKpiClientesActivos(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi5 = firstOf(partnerRepository.findKpiUsoPromedioPlan(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi6 = firstOf(partnerRepository.findKpiTasaEntregaMensajes(idEntidad, anio, periodo, tipoFiltro)).orElse(null);

        return PartnerDashboardDTO.builder()
                .totalFacturado(kpi1 != null ? kpi1.getTotalFacturado() : null)
                .totalCobrado(kpi2 != null ? kpi2.getTotalCobrado() : null)
                .carteraVencida(kpi3 != null ? kpi3.getCarteraVencida() : null)
                .clientesActivos(kpi4 != null ? kpi4.getClientesActivos() : null)
                .usoPromedioPorcentaje(kpi5 != null ? kpi5.getUsoPromedioPorcentaje() : null)
                .tasaEntrega(kpi6 != null ? kpi6.getTasaEntrega() : null)
                .build();
    }

    // Reportes contexto
    public List<FacturadoVsCobradoClienteDTO> getReporte9FacturadoVsCobrado(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return partnerRepository.findReporte9FacturadoVsCobrado(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<AgingCarteraDTO> getReporte10AgingCartera(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return partnerRepository.findReporte10AgingCartera(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<UsoVsPlanPartnerDTO> getReporte11UsoVsPlan(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return partnerRepository.findReporte11UsoVsPlan(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<DeterioroLlamadasDTO> getReporte14DeterioroLlamadas(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return partnerRepository.findReporte14DeterioroLlamadas(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<CalidadMensajeriaClienteDTO> getReporte15CalidadMensajeria(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return partnerRepository.findReporte15CalidadMensajeria(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<CrecimientoNetoClientesDTO> getCrecimientoNetoClientes(Integer idEntidad, Integer anio) {
        return partnerRepository.findCrecimientoNetoClientes(idEntidad, anio);
    }

    // Detalle granular
    public List<MesaOperativaDTO> getReporte16MesaOperativa(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return partnerRepository.findReporte16MesaOperativa(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<VencimientoContratoDTO> getVencimientosContratos(Integer idEntidad) {
        return partnerRepository.findVencimientosContratos(idEntidad);
    }

    // Search (accepts empty string → SQL returns all via ILIKE '%%')
    public List<PartnerSearchResultDTO> searchPartners(String query) {
        return partnerRepository.searchPartners(query == null ? "" : query.trim());
    }

    // All partners — used by the dropdown selector (no query param needed)
    public List<PartnerSearchResultDTO> getAllPartners() {
        return partnerRepository.searchPartners("");
    }

    // Info by ID — resolves name/estado without needing the search endpoint
    public Optional<PartnerSearchResultDTO> getPartnerInfo(Integer id) {
        List<PartnerSearchResultDTO> results = partnerRepository.findPartnerById(id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    private <T> Optional<T> firstOf(List<T> list) {
        return (list == null || list.isEmpty()) ? Optional.empty() : Optional.of(list.get(0));
    }
}
