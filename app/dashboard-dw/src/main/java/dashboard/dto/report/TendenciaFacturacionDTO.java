package dashboard.dto.report;

import java.math.BigDecimal;

public interface TendenciaFacturacionDTO {
    String getNombrePartner();
    Integer getAnioReporte();
    BigDecimal getTotalFacturado();
    BigDecimal getVariacionPct();
}
