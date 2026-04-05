package dashboard.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class PartnerDashboardDTO {
    private BigDecimal totalFacturado;
    private BigDecimal totalCobrado;
    private BigDecimal carteraVencida;
    private Integer clientesActivos;
    private BigDecimal usoPromedioPorcentaje;
    private BigDecimal tasaEntrega;
}
