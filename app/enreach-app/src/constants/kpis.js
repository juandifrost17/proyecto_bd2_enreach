export const KPI_CONFIG = Object.freeze({
  enreach: [
    { key: 'totalFacturado', label: 'Facturación global', format: 'currencyCompact' },
    { key: 'totalCobrado', label: 'Ingresos cobrados', format: 'currencyCompact' },
    { key: 'saldoPendiente', label: 'Saldo pendiente', format: 'currencyCompact', status: 'mora' },
    { key: 'partnersActivos', label: 'Partners activos', format: 'integer' },
    { key: 'tasaContestacion', label: 'Tasa contestación', format: 'percent' },
    { key: 'tasaEntrega', label: 'Tasa entrega', format: 'percent' },
  ],
  partner: [
    { key: 'facturacionPeriodo', label: 'Facturación del periodo', format: 'currencyCompact' },
    { key: 'cobroPeriodo', label: 'Cobro del periodo', format: 'currencyCompact' },
    { key: 'carteraVencida', label: 'Cartera vencida', format: 'currencyCompact', status: 'mora' },
    { key: 'clientesActivos', label: 'Clientes activos', format: 'integer' },
    { key: 'usoPromedioPlan', label: 'Uso promedio del plan', format: 'percent' },
    { key: 'tasaEntrega', label: 'Tasa entrega', format: 'percent' },
  ],
  cliente: [
    { key: 'gastoPeriodo', label: 'Gasto del periodo', format: 'currencyCompact' },
    { key: 'montoPagado', label: 'Monto pagado', format: 'currencyCompact' },
    { key: 'saldoPendiente', label: 'Saldo pendiente', format: 'currencyCompact', status: 'mora' },
    { key: 'usoMinutos', label: 'Uso de minutos', format: 'integer' },
    { key: 'usoMensajes', label: 'Uso de mensajes', format: 'integer' },
    { key: 'colasFueraSla', label: 'Colas fuera de SLA', format: 'integer', status: 'sla' },
  ],
});
