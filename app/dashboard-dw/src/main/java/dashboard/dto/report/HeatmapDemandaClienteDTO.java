package dashboard.dto.report;

/**
 * Reporte 21 (Cliente): Saturación horaria por filial y cola
 * SQL: fn_reporte_21_saturacion_horaria
 * Retorna: nombreFilial, nombreCola, diaSemana, hora, volumenLlamadas
 */
public interface HeatmapDemandaClienteDTO {
    String getNombreFilial();
    String getNombreCola();
    String getDiaSemana();
    Integer getHora();
    Long getVolumenLlamadas();
}
