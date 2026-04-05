package dashboard.dto.report;

import java.math.BigDecimal;

public interface RevenuePorPaisDTO {
    String getPaisPartner();
    Integer getTotalClientes();
    BigDecimal getTotalFacturado();
    BigDecimal getSaldoPendiente();
}
