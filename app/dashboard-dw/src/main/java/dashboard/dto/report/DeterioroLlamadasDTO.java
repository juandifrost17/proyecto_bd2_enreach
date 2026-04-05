package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 14 (Partner): Deterioro de llamadas perdidas y abandonadas
 * SQL: fn_reporte_14_deterioro_llamadas
 */
public interface DeterioroLlamadasDTO {
    String getNombreCliente();
    Long getTotalLlamadas();
    Long getPerdidas();
    Long getAbandonadas();
    BigDecimal getTasaPerdida();
    BigDecimal getTasaAbandono();
    Long getTotalRegistros();
}
