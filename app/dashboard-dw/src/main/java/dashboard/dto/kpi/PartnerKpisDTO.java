package dashboard.dto.kpi;

import java.math.BigDecimal;

/**
 * Projection para KPIs del Dashboard Partner.
 *
 * Cada función SQL retorna UNA sola columna:
 *   fn_kpi_partner_1 → totalFacturado
 *   fn_kpi_partner_2 → totalCobrado
 *   fn_kpi_partner_3 → carteraVencida
 *   fn_kpi_partner_4 → clientesActivos
 *   fn_kpi_partner_5 → usoPromedioPorcentaje
 *   fn_kpi_partner_6 → tasaEntrega
 */
public interface PartnerKpisDTO {
    BigDecimal getTotalFacturado();
    BigDecimal getTotalCobrado();
    BigDecimal getCarteraVencida();
    Integer getClientesActivos();
    BigDecimal getUsoPromedioPorcentaje();
    BigDecimal getTasaEntrega();
}
