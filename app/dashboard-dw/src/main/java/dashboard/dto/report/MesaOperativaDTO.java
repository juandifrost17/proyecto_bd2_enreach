package dashboard.dto.report;

import java.math.BigDecimal;

/**
 * Reporte 16 (Partner): Mesa operativa de clientes críticos
 * SQL: fn_reporte_16_mesa_operativa_clientes
 * Retorna: nombreCliente, saldoPendiente, diasMora, usoPlanPorcentaje, tasaPerdidaLlamadas, tasaEntregaMensajes, colaCritica
 */
public interface MesaOperativaDTO {
    String getNombreCliente();
    BigDecimal getSaldoPendiente();
    Integer getDiasMora();
    BigDecimal getUsoPlanPorcentaje();
    BigDecimal getTasaPerdidaLlamadas();
    BigDecimal getTasaEntregaMensajes();
    String getColaCritica();
}
