package dashboard.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class ClienteDashboardDTO {
    private BigDecimal totalGasto;
    private BigDecimal totalPagado;
    private BigDecimal saldoPendiente;
    private BigDecimal totalMinutos;
    private Long totalMensajes;
    private Integer colasFueraSLA;
}
