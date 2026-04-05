package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 3 (Enreach): Riesgo financiero por partner
 * SQL: fn_reporte_3_riesgo_financiero
 * Retorna: nombrePartner, saldoPendiente, diasMoraPromedio, contratosActivos
 */
public interface RiesgoComercialDTO {
    String getNombrePartner();
    BigDecimal getSaldoPendiente();
    BigDecimal getDiasMoraPromedio();
    Integer getContratosActivos();
}
