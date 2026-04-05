package dashboard.dto.report;

import java.time.LocalDate;

public interface VencimientoContratoDTO {
    String getNombreCliente();
    String getNombrePlan();
    String getEstadoContrato();
    LocalDate getFechaFin();
    Integer getDiasRestantes();
    String getUrgencia();
}
