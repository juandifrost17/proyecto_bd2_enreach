package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 8 (Enreach): Scorecard operativo de partners críticos
 * SQL: fn_reporte_8_scorecard_partners
 * Retorna: nombrePartner, revenue, saldoPendiente, diasMora, tasaPerdida, tasaAbandono, tasaEntregaMensajes
 */
public interface ScorecardEjecutivoDTO {
    String getNombrePartner();
    BigDecimal getRevenue();
    BigDecimal getSaldoPendiente();
    Integer getDiasMora();
    BigDecimal getTasaPerdida();
    BigDecimal getTasaAbandono();
    BigDecimal getTasaEntregaMensajes();
}
