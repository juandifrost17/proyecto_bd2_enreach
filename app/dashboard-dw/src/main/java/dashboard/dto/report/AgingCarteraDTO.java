package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 10 (Partner): Aging de cartera por cliente
 * SQL: fn_reporte_10_aging_cartera_cliente
 */
public interface AgingCarteraDTO {
    String getNombreCliente();
    String getRangoDias();
    Integer getOrdenBucket();
    BigDecimal getSaldoPendiente();
}
