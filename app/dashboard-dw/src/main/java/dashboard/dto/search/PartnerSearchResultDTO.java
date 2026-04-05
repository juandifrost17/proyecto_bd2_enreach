package dashboard.dto.search;

/**
 * DTO para resultados de búsqueda de Partners.
 * Usado en autocomplete de "Vista Partner"
 */
public interface PartnerSearchResultDTO {
    Integer getId();
    String getNombre();        // nombre_partner
    String getEstado();        // estado_partner ('ACTIVO', 'INACTIVO')
}