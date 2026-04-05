package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 6 (Enreach): Salud de mensajería por partner
 * SQL: fn_reporte_6_salud_mensajeria_partner
 * Retorna: nombrePartner, totalMensajes, entregados, tasaEntrega, mensajesGrupo, mensajesDirecto
 */
public interface SaludMensajeriaPartnerDTO {
    String getNombrePartner();
    Long getTotalMensajes();
    Long getEntregados();
    BigDecimal getTasaEntrega();
    Long getMensajesGrupo();
    Long getMensajesDirecto();
}
