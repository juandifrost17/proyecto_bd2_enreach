package dashboard.dto.report;

import java.math.BigDecimal;

public interface EmbudoContactoFilialDTO {
    String getNombreFilial();
    Long getIntentosTotales();
    Long getLogrados();
    Long getFallidos();
    BigDecimal getPctEfectividad();
}
