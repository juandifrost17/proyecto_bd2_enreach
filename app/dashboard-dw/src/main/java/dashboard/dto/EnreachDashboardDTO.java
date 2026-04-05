package dashboard.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class EnreachDashboardDTO {
    private BigDecimal totalFacturado;
    private BigDecimal totalCobrado;
    private BigDecimal saldoPendienteTotal;
    private Integer partnersActivos;
    private BigDecimal tasaContestacion;
    private BigDecimal tasaEntregaMensajes;
}
