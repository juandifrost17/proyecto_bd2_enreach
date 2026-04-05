package dashboard.dto.search;

/**
 * DTO para resultados de búsqueda de Clientes.
 * Usado en autocomplete de "Vista Cliente"
 */
public interface ClienteSearchResultDTO {
    Integer getId();
    String getNombre();        // razon_social
    String getEstado();        // estado_cliente ('ACTIVO', 'INACTIVO')
}