package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 9 (Partner): Facturado vs cobrado por CLIENTE
 * SQL: fn_reporte_9_facturado_cobrado_cliente
 * Retorna: nombreCliente, totalFacturado, totalCobrado, saldoPendiente
 */
public interface FacturadoVsCobradoClienteDTO {
    String getNombreCliente();
    BigDecimal getTotalFacturado();
    BigDecimal getTotalCobrado();
    BigDecimal getSaldoPendiente();
}
