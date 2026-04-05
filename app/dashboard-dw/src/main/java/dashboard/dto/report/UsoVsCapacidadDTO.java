package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 20 (Cliente): Uso de minutos y mensajes vs capacidad contratada
 * SQL: fn_reporte_20_uso_vs_capacidad
 * Retorna: nombreFilial, minutosConsumidos, minutosCapacidad, mensajesConsumidos, mensajesCapacidad
 */
public interface UsoVsCapacidadDTO {
    String getNombreFilial();
    BigDecimal getMinutosConsumidos();
    BigDecimal getMinutosCapacidad();
    Long getMensajesConsumidos();
    Long getMensajesCapacidad();
}
