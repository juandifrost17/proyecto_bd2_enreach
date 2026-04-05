package dashboard.dto.report;

import java.math.BigDecimal;
import java.time.LocalDate;

public interface VencimientoAcuerdoDTO {
    String getNombrePartner();
    Integer getNivelAcuerdo();
    String getEstadoAcuerdo();
    LocalDate getFechaFin();
    Integer getDiasRestantes();
    BigDecimal getRevenueTotal();
    String getUrgencia();
}
