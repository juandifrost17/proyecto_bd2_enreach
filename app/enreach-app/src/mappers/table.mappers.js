import {
  applyQuickFilters,
  getMoraLevel,
  getRiskLevel,
  getSlaLevel,
  normalizeNumber,
  normalizeText,
  pickFirstDefined,
} from '@/mappers/common.mappers';

export function paginateRows(rows = [], currentPage = 1, pageSize = 10) {
  const safePageSize = Math.max(1, Number(pageSize) || 10);
  const safePage = Math.max(1, Number(currentPage) || 1);
  const start = (safePage - 1) * safePageSize;

  return {
    rows: rows.slice(start, start + safePageSize),
    total: rows.length,
    totalPages: Math.max(1, Math.ceil(rows.length / safePageSize)),
    currentPage: safePage,
    pageSize: safePageSize,
    startIndex: rows.length === 0 ? 0 : start + 1,
    endIndex: Math.min(start + safePageSize, rows.length),
  };
}

export function mapScorecardTable(items = [], quickFilters = {}) {
  const rows = applyQuickFilters(items.map((item, index) => ({
    id: pickFirstDefined(item, ['id', 'idPartner', 'idCliente'], index + 1),
    partnerName: normalizeText(pickFirstDefined(item, ['nombrePartner', 'partner', 'nombre'])),
    revenue: normalizeNumber(pickFirstDefined(item, ['revenue', 'facturado', 'montoFacturado'])),
    saldoPendiente: normalizeNumber(pickFirstDefined(item, ['saldoPendiente', 'pendiente'])),
    diasMora: normalizeNumber(pickFirstDefined(item, ['diasMora', 'moraDias'])),
    tasaPerdida: normalizeNumber(pickFirstDefined(item, ['tasaPerdida', 'porcentajePerdida'])),
    tasaAbandono: normalizeNumber(pickFirstDefined(item, ['tasaAbandono', 'porcentajeAbandono'])),
    tasaEntregaMensajes: normalizeNumber(pickFirstDefined(item, ['tasaEntregaMensajes', 'tasaEntrega'])),
    criticality: getMoraLevel(pickFirstDefined(item, ['diasMora', 'moraDias'], 0)),
  })), quickFilters);

  const columns = [
    { key: 'partnerName', label: 'Partner', align: 'left' },
    { key: 'revenue', label: 'Facturado', align: 'right', format: 'currency' },
    { key: 'saldoPendiente', label: 'Pendiente', align: 'right', format: 'currency' },
    { key: 'diasMora', label: 'Mora', align: 'right', format: 'days' },
    { key: 'tasaPerdida', label: 'Pérdida', align: 'right', format: 'percent' },
    { key: 'tasaAbandono', label: 'Abandono', align: 'right', format: 'percent' },
    { key: 'tasaEntregaMensajes', label: 'Mensajería', align: 'right', format: 'percent' },
    { key: 'criticality', label: 'Criticidad', align: 'center', format: 'sla' },
  ];

  return { columns, rows };
}

export function mapChurnTable(items = [], quickFilters = {}) {
  const rows = applyQuickFilters(items.map((item, index) => ({
    id: index + 1,
    cliente: normalizeText(item.nombreCliente),
    volumenLlamadas: normalizeNumber(item.volumenLlamadas),
    tasaPerdida: normalizeNumber(item.tasaPerdida),
    tasaEntregaMensajes: normalizeNumber(item.tasaEntregaMensajes),
    riskLevel: getRiskLevel(item.indicadorRiesgo),
    criticality: getRiskLevel(item.indicadorRiesgo),
  })), quickFilters);

  const columns = [
    { key: 'cliente', label: 'Cliente', align: 'left' },
    { key: 'volumenLlamadas', label: 'Llamadas', align: 'right' },
    { key: 'tasaPerdida', label: 'Pérdida', align: 'right', format: 'percent' },
    { key: 'tasaEntregaMensajes', label: 'Entrega', align: 'right', format: 'percent' },
    { key: 'riskLevel', label: 'Riesgo', align: 'center', format: 'risk' },
  ];

  return { columns, rows };
}

export function mapMesaOperativaTable(items = [], quickFilters = {}) {
  const rows = applyQuickFilters(items.map((item, index) => {
    const diasMora = normalizeNumber(item.diasMora);
    const usagePct = normalizeNumber(item.usoPlanPorcentaje);
    const lossPct = normalizeNumber(item.tasaPerdidaLlamadas);
    const deliveryPct = normalizeNumber(item.tasaEntregaMensajes);

    let riskLevel = 'ok';
    if (diasMora > 30 || usagePct >= 90 || lossPct >= 8) {
      riskLevel = 'critical';
    } else if (diasMora > 0 || usagePct >= 75 || lossPct >= 4 || deliveryPct < 95) {
      riskLevel = 'warning';
    }

    const cumpleSla = deliveryPct >= 95;

    return {
      id: index + 1,
      cliente: normalizeText(item.nombreCliente),
      saldoPendiente: normalizeNumber(item.saldoPendiente),
      diasMora,
      usoPlanPorcentaje: usagePct,
      tasaPerdidaLlamadas: lossPct,
      tasaEntregaMensajes: deliveryPct,
      colaCritica: normalizeText(item.colaCritica),
      riskLevel,
      slaStatus: getSlaLevel(cumpleSla),
      cumpleSla,
      criticality: riskLevel,
    };
  }), quickFilters);

  const columns = [
    { key: 'cliente', label: 'Cliente', align: 'left' },
    { key: 'saldoPendiente', label: 'Pendiente', align: 'right', format: 'currency' },
    { key: 'diasMora', label: 'Mora', align: 'right', format: 'days' },
    { key: 'usoPlanPorcentaje', label: 'Uso plan', align: 'right', format: 'percent' },
    { key: 'tasaPerdidaLlamadas', label: 'Pérdida voz', align: 'right', format: 'percent' },
    { key: 'tasaEntregaMensajes', label: 'Entrega', align: 'right', format: 'percent' },
    { key: 'riskLevel', label: 'Riesgo', align: 'center', format: 'risk' },
  ];

  return { columns, rows };
}

export function mapEstadoPagosTable(items = [], quickFilters = {}) {
  const rows = applyQuickFilters(items.map((item, index) => {
    const diasMora = normalizeNumber(item.diasMora);
    return {
      id: pickFirstDefined(item, ['idFactura', 'id'], index + 1),
      documento: normalizeText(pickFirstDefined(item, ['nombrePlan', 'factura', 'documento'])),
      estado: diasMora > 0 ? 'pendiente' : 'pagada',
      monto: normalizeNumber(item.montoTotal),
      saldoPendiente: normalizeNumber(item.saldoPendiente),
      diasMora,
      criticality: getMoraLevel(diasMora),
    };
  }), quickFilters);

  const columns = [
    { key: 'documento', label: 'Concepto', align: 'left' },
    { key: 'estado', label: 'Estado', align: 'center', format: 'status' },
    { key: 'monto', label: 'Monto', align: 'right', format: 'currency' },
    { key: 'saldoPendiente', label: 'Pendiente', align: 'right', format: 'currency' },
    { key: 'diasMora', label: 'Mora', align: 'right', format: 'days' },
    { key: 'criticality', label: 'Criticidad', align: 'center', format: 'sla' },
  ];

  return { columns, rows };
}

export function mapUsuariosNoContestacionTable(items = [], quickFilters = {}) {
  const rows = applyQuickFilters(items.map((item, index) => {
    const tasaNoContestacion = normalizeNumber(item.tasaNoContestacion);
    const criticality = tasaNoContestacion >= 20 ? 'critical' : tasaNoContestacion >= 10 ? 'warning' : 'ok';
    return {
      id: index + 1,
      usuario: normalizeText(item.nombreUsuario),
      did: normalizeText(item.numeroDid),
      totalLlamadas: normalizeNumber(item.totalLlamadas),
      noContestadas: normalizeNumber(item.noContestadas),
      tasaNoContestacion,
      criticality,
    };
  }), quickFilters);

  const columns = [
    { key: 'usuario', label: 'Usuario', align: 'left' },
    { key: 'did', label: 'DID', align: 'left' },
    { key: 'noContestadas', label: 'No cont.', align: 'right' },
    { key: 'tasaNoContestacion', label: 'Tasa', align: 'right', format: 'percent' },
    { key: 'criticality', label: 'Criticidad', align: 'center', format: 'sla' },
  ];

  return { columns, rows };
}

// ── MAPPERS TABLAS NUEVOS ───────────────────────────────────────────────────

export function mapVencimientosAcuerdosTable(items = []) {
  const rows = items.map((item, index) => ({
    id: index + 1,
    partner: normalizeText(item.nombrePartner),
    nivel: normalizeNumber(item.nivelAcuerdo),
    estado: normalizeText(item.estadoAcuerdo),
    fechaFin: normalizeText(item.fechaFin),
    diasRestantes: normalizeNumber(item.diasRestantes),
    revenue: normalizeNumber(item.revenueTotal),
    urgencia: normalizeText(item.urgencia),
    criticality: getRiskLevel(item.urgencia),
  }));
  const columns = [
    { key: 'partner', label: 'Partner', align: 'left' },
    { key: 'estado', label: 'Estado', align: 'center', format: 'status' },
    { key: 'fechaFin', label: 'Vence', align: 'right' },
    { key: 'diasRestantes', label: 'Días rest.', align: 'right' },
    { key: 'revenue', label: 'Revenue', align: 'right', format: 'currency' },
    { key: 'urgencia', label: 'Urgencia', align: 'center', format: 'risk' },
  ];
  return { columns, rows };
}

export function mapAdopcionIntegracionesTable(items = []) {
  const rows = items.map((item, index) => ({
    id: index + 1,
    cliente: normalizeText(item.nombreCliente),
    integracion: normalizeText(item.integracion),
    tipo: normalizeText(item.tipoIntegracion),
    proveedor: normalizeText(item.proveedor),
    estado: normalizeText(item.estadoInteg),
    diasSinSync: normalizeNumber(item.diasSinSync),
    criticality: normalizeNumber(item.diasSinSync) > 30 ? 'critical' : normalizeNumber(item.diasSinSync) > 7 ? 'warning' : 'ok',
  }));
  const columns = [
    { key: 'cliente', label: 'Cliente', align: 'left' },
    { key: 'integracion', label: 'Integración', align: 'left' },
    { key: 'proveedor', label: 'Proveedor', align: 'left' },
    { key: 'estado', label: 'Estado', align: 'center', format: 'status' },
    { key: 'diasSinSync', label: 'Días sin sync', align: 'right', format: 'days' },
    { key: 'criticality', label: 'Criticidad', align: 'center', format: 'sla' },
  ];
  return { columns, rows };
}

export function mapVencimientosContratosTable(items = []) {
  const rows = items.map((item, index) => ({
    id: index + 1,
    cliente: normalizeText(item.nombreCliente),
    plan: normalizeText(item.nombrePlan),
    estado: normalizeText(item.estadoContrato),
    fechaFin: normalizeText(item.fechaFin),
    diasRestantes: normalizeNumber(item.diasRestantes),
    urgencia: normalizeText(item.urgencia),
    criticality: getRiskLevel(item.urgencia),
  }));
  const columns = [
    { key: 'cliente', label: 'Cliente', align: 'left' },
    { key: 'plan', label: 'Plan', align: 'left' },
    { key: 'estado', label: 'Estado', align: 'center', format: 'status' },
    { key: 'fechaFin', label: 'Vence', align: 'right' },
    { key: 'diasRestantes', label: 'Días rest.', align: 'right' },
    { key: 'urgencia', label: 'Urgencia', align: 'center', format: 'risk' },
  ];
  return { columns, rows };
}

export function mapEstadoIntegracionesTable(items = []) {
  const rows = items.map((item, index) => ({
    id: index + 1,
    integracion: normalizeText(item.nombreIntegracion),
    tipo: normalizeText(item.tipoIntegracion),
    proveedor: normalizeText(item.proveedor),
    estado: normalizeText(item.estadoInteg),
    diasSinSync: normalizeNumber(item.diasSinSync),
    criticality: normalizeNumber(item.diasSinSync) > 30 ? 'critical' : normalizeNumber(item.diasSinSync) > 7 ? 'warning' : 'ok',
  }));
  const columns = [
    { key: 'integracion', label: 'Integración', align: 'left' },
    { key: 'tipo', label: 'Tipo', align: 'left' },
    { key: 'proveedor', label: 'Proveedor', align: 'left' },
    { key: 'estado', label: 'Estado', align: 'center', format: 'status' },
    { key: 'diasSinSync', label: 'Días sin sync', align: 'right', format: 'days' },
    { key: 'criticality', label: 'Criticidad', align: 'center', format: 'sla' },
  ];
  return { columns, rows };
}

export function mapGruposColaboracionTable(items = []) {
  const rows = items.map((item, index) => ({
    id: index + 1,
    grupo: normalizeText(item.nombreGrupo),
    volumen: normalizeNumber(item.volumenMensajes),
    tasaRespuesta: normalizeNumber(item.tasaRespuesta),
    tasaEntrega: normalizeNumber(item.tasaEntrega),
  }));
  const columns = [
    { key: 'grupo', label: 'Grupo', align: 'left' },
    { key: 'volumen', label: 'Mensajes', align: 'right' },
    { key: 'tasaRespuesta', label: 'Respuesta', align: 'right', format: 'percent' },
    { key: 'tasaEntrega', label: 'Entrega', align: 'right', format: 'percent' },
  ];
  return { columns, rows };
}
