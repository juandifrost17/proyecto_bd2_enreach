package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 11 (Partner): Uso real vs plan contratado
 * SQL: fn_reporte_11_uso_real_vs_plan
 * Retorna: nombreCliente, nombrePlan, minutosConsumidos, minutosIncluidos, mensajesConsumidos, mensajesIncluidos
 */
public interface UsoVsPlanPartnerDTO {
    String getNombreCliente();
    String getNombrePlan();
    BigDecimal getMinutosConsumidos();
    BigDecimal getMinutosIncluidos();
    Long getMensajesConsumidos();
    Long getMensajesIncluidos();
}
