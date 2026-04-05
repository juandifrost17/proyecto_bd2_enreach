package dashboard.dto.kpi;

import java.math.BigDecimal;

/**
 * Projection para KPIs del Dashboard Cliente.
 *
 * Cada función SQL retorna UNA sola columna:
 *   fn_kpi_cliente_1 → totalGasto
 *   fn_kpi_cliente_2 → totalPagado
 *   fn_kpi_cliente_3 → saldoPendiente
 *   fn_kpi_cliente_4 → totalMinutos
 *   fn_kpi_cliente_5 → totalMensajes
 *   fn_kpi_cliente_6 → colasFueraSLA
 */
public interface ClienteKpisDTO {
    BigDecimal getTotalGasto();
    BigDecimal getTotalPagado();
    BigDecimal getSaldoPendiente();
    BigDecimal getTotalMinutos();
    Long getTotalMensajes();
    Integer getColasFueraSLA();
}
