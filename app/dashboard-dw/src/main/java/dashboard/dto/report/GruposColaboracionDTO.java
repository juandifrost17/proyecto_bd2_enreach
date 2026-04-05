package dashboard.dto.report;

import java.math.BigDecimal;

public interface GruposColaboracionDTO {
    String getNombreGrupo();
    Long getVolumenMensajes();
    BigDecimal getTasaRespuesta();
    BigDecimal getTasaEntrega();
}
