package dashboard.dto.report;

import java.math.BigDecimal;

public interface TendenciaComunicacionesDTO {
    Integer getAnioReporte();
    Integer getMesReporte();
    Long getTotalLlamadas();
    Long getTotalMensajes();
    BigDecimal getTotalMinutos();
}
