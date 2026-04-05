package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 5 (Enreach): Calidad de llamadas por partner
 * SQL: fn_reporte_5_calidad_llamadas_partner
 * Retorna: nombrePartner, totalLlamadas, contestadas, perdidas, abandonadas, tasaContestacion
 */
public interface CalidadLlamadasDTO {
    String getNombrePartner();
    Long getTotalLlamadas();
    Long getContestadas();
    Long getPerdidas();
    Long getAbandonadas();
    BigDecimal getTasaContestacion();
}
