package dashboard.dto.report;

import java.math.BigDecimal;

public interface CostoPorInteraccionDTO {
    Integer getMesReporte();
    BigDecimal getCostoPorInteraccion();
    BigDecimal getPromedioMovil3m();
}
