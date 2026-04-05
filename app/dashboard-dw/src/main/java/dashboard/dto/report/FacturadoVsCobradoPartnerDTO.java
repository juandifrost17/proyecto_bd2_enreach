package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 1 (Enreach): Facturado vs cobrado por PARTNER
 * SQL: fn_reporte_1_facturado_vs_cobrado
 * Retorna: nombrePartner, totalFacturado, totalCobrado, saldoPendiente
 */
public interface FacturadoVsCobradoPartnerDTO {
    String getNombrePartner();
    BigDecimal getTotalFacturado();
    BigDecimal getTotalCobrado();
    BigDecimal getSaldoPendiente();
}
