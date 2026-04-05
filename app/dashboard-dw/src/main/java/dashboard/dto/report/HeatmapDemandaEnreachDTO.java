package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 4 (Enreach): Demanda horaria global de voz
 * SQL: fn_reporte_4_demanda_horaria_voz
 * Retorna: diaSemana, hora, volumenLlamadas
 */
public interface HeatmapDemandaEnreachDTO {
    String getDiaSemana();
    Integer getHora();
    Long getVolumenLlamadas();
}
