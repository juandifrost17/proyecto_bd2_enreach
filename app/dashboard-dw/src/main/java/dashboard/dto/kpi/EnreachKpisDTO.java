package dashboard.dto.kpi;

import java.math.BigDecimal;

/**
 * Projection para KPIs del Dashboard Enreach.
 *
 * Cada función SQL retorna UNA sola columna:
 *   fn_kpi_enreach_1 → totalFacturado
 *   fn_kpi_enreach_2 → totalCobrado
 *   fn_kpi_enreach_3 → saldoPendienteTotal
 *   fn_kpi_enreach_4 → partnersActivos
 *   fn_kpi_enreach_5 → tasaContestacion
 *   fn_kpi_enreach_6 → tasaEntregaMensajes
 *
 * Spring projection devuelve null para getters sin columna en el result set.
 */
public interface EnreachKpisDTO {
    BigDecimal getTotalFacturado();
    BigDecimal getTotalCobrado();
    BigDecimal getSaldoPendienteTotal();
    Integer getPartnersActivos();
    BigDecimal getTasaContestacion();
    BigDecimal getTasaEntregaMensajes();
}
