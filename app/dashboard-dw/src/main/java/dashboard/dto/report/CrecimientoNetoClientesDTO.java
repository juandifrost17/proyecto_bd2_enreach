package dashboard.dto.report;

public interface CrecimientoNetoClientesDTO {
    Integer getAnioReporte();
    Integer getTrimestreReporte();
    Long getAltas();
    Long getBajas();
    Long getNeto();
}
