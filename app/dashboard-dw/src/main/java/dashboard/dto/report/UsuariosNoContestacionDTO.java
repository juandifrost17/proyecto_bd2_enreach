package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 22 (Cliente): Usuarios con mayor no contestación
 * SQL: fn_reporte_22_usuarios_no_contestacion
 * Retorna: nombreUsuario, numeroDid, totalLlamadas, noContestadas, tasaNoContestacion
 */
public interface UsuariosNoContestacionDTO {
    String getNombreUsuario();
    String getNumeroDid();
    Long getTotalLlamadas();
    Long getNoContestadas();
    BigDecimal getTasaNoContestacion();
}
