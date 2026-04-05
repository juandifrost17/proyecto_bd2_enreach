package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 15 (Partner): Calidad y adopción de mensajería por cliente
 * SQL: fn_reporte_15_calidad_mensajeria_cliente
 * Retorna: nombreCliente, totalMensajes, tasaEntrega, tasaRespuesta, mensajesGrupo, mensajesDirectos
 */
public interface CalidadMensajeriaClienteDTO {
    String getNombreCliente();
    Long getTotalMensajes();
    BigDecimal getTasaEntrega();
    BigDecimal getTasaRespuesta();
    Long getMensajesGrupo();
    Long getMensajesDirectos();
}
