package dashboard.service;

import dashboard.dto.EnreachDashboardDTO;
import dashboard.dto.kpi.EnreachKpisDTO;
import dashboard.dto.report.*;
import dashboard.repository.EnreachDashboardRepository;
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
public class EnreachDashboardService {

    private final EnreachDashboardRepository enreachRepository;

    // KPIs individuales
    public Optional<EnreachKpisDTO> getFacturacionTotal(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(enreachRepository.findKpiFacturacionTotal(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<EnreachKpisDTO> getCobroTotal(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(enreachRepository.findKpiCobroTotal(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<EnreachKpisDTO> getSaldoPendiente(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(enreachRepository.findKpiSaldoPendiente(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<EnreachKpisDTO> getPartnersActivos(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(enreachRepository.findKpiPartnersActivos(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<EnreachKpisDTO> getTasaContestacion(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(enreachRepository.findKpiTasaContestacion(idEntidad, anio, periodo, tipoFiltro));
    }

    public Optional<EnreachKpisDTO> getTasaEntrega(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return firstOf(enreachRepository.findKpiTasaEntrega(idEntidad, anio, periodo, tipoFiltro));
    }

    // KPIs combinados
    public EnreachDashboardDTO getAllKpis(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        log.info("Cargando todos los KPIs de Enreach - Entity: {}, Period: {}/{}/{}", idEntidad, anio, periodo, tipoFiltro);
        var kpi1 = firstOf(enreachRepository.findKpiFacturacionTotal(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi2 = firstOf(enreachRepository.findKpiCobroTotal(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi3 = firstOf(enreachRepository.findKpiSaldoPendiente(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi4 = firstOf(enreachRepository.findKpiPartnersActivos(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi5 = firstOf(enreachRepository.findKpiTasaContestacion(idEntidad, anio, periodo, tipoFiltro)).orElse(null);
        var kpi6 = firstOf(enreachRepository.findKpiTasaEntrega(idEntidad, anio, periodo, tipoFiltro)).orElse(null);

        return EnreachDashboardDTO.builder()
                .totalFacturado(kpi1 != null ? kpi1.getTotalFacturado() : null)
                .totalCobrado(kpi2 != null ? kpi2.getTotalCobrado() : null)
                .saldoPendienteTotal(kpi3 != null ? kpi3.getSaldoPendienteTotal() : null)
                .partnersActivos(kpi4 != null ? kpi4.getPartnersActivos() : null)
                .tasaContestacion(kpi5 != null ? kpi5.getTasaContestacion() : null)
                .tasaEntregaMensajes(kpi6 != null ? kpi6.getTasaEntregaMensajes() : null)
                .build();
    }

    // Reportes contexto
    public List<FacturadoVsCobradoPartnerDTO> getReporte1FacturadoVsCobrado(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return enreachRepository.findReporte1FacturadoVsCobrado(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<RiesgoComercialDTO> getReporte3RiesgoFinanciero(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return enreachRepository.findReporte3RiesgoFinanciero(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<HeatmapDemandaEnreachDTO> getReporte4DemandaHoraria(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return enreachRepository.findReporte4DemandaHoraria(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<CalidadLlamadasDTO> getReporte5CalidadLlamadas(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return enreachRepository.findReporte5CalidadLlamadas(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<SaludMensajeriaPartnerDTO> getReporte6SaludMensajeria(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return enreachRepository.findReporte6SaludMensajeria(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<TendenciaFacturacionDTO> getTendenciaFacturacionAnual(Integer idEntidad, Integer anio) {
        return enreachRepository.findTendenciaFacturacionAnual(idEntidad, anio);
    }

    public List<RevenuePorPaisDTO> getRevenuePorPais(Integer idEntidad, Integer anio) {
        return enreachRepository.findRevenuePorPais(idEntidad, anio);
    }

    // Detalle granular
    public List<ScorecardEjecutivoDTO> getReporte8Scorecard(Integer idEntidad, Integer anio, Integer periodo, String tipoFiltro) {
        return enreachRepository.findReporte8Scorecard(idEntidad, anio, periodo, tipoFiltro);
    }

    public List<VencimientoAcuerdoDTO> getVencimientosAcuerdos(Integer idEntidad) {
        return enreachRepository.findVencimientosAcuerdos(idEntidad);
    }

    private <T> Optional<T> firstOf(List<T> list) {
        return (list == null || list.isEmpty()) ? Optional.empty() : Optional.of(list.get(0));
    }
}
