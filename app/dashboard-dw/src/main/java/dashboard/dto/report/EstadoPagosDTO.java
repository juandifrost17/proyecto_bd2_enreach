package dashboard.dto.report;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Reporte 19 (Cliente): Estado de pagos, facturas y mora
 * SQL: fn_reporte_19_estado_pagos_facturas
 * Retorna: idFactura, fechaEmision, nombrePlan, estadoFactura, metodoPago, montoTotal, montoPagado, saldoPendiente, diasMora
 */
public interface EstadoPagosDTO {
    Integer getIdFactura();
    LocalDate getFechaEmision();
    String getNombrePlan();
    String getEstadoFactura();
    String getMetodoPago();
    BigDecimal getMontoTotal();
    BigDecimal getMontoPagado();
    BigDecimal getSaldoPendiente();
    Integer getDiasMora();
}
