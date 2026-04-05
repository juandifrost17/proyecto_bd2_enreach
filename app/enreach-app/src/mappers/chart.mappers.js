import {
  getRiskLevel,
  normalizeNumber,
  normalizeText,
  pickFirstDefined,
} from '@/mappers/common.mappers';

function buildWaterfallType(concepto) {
  const raw = normalizeText(concepto, '').toUpperCase();
  if (raw === 'DESCUENTO' || raw === 'TOTAL_PAGADO') return 'decrease';
  if (raw === 'TOTAL_FACTURA' || raw === 'SALDO_PENDIENTE') return 'total';
  return 'increase';
}

function buildWaterfallLabel(concepto) {
  const raw = normalizeText(concepto, '').toUpperCase();
  const labels = {
    SUBTOTAL: 'Bruto',
    DESCUENTO: 'Descuento',
    IMPUESTO: 'Impuesto',
    TOTAL_FACTURA: 'Neto',
    TOTAL_PAGADO: 'Cobrado',
    SALDO_PENDIENTE: 'Pendiente',
  };
  return labels[raw] || normalizeText(concepto);
}

function inferRiskLevel(item) {
  const saldoPendiente = normalizeNumber(item.saldoPendiente);
  const diasMora = normalizeNumber(item.diasMoraPromedio);

  if (diasMora >= 90 || saldoPendiente >= 400000) return 'critical';
  if (diasMora >= 45 || saldoPendiente >= 200000) return 'warning';
  return 'ok';
}

export function mapFacturadoVsCobrado(items = []) {
  return items.map((item, index) => ({
    id: pickFirstDefined(item, ['idEntidad', 'idPartner', 'idCliente', 'id'], index + 1),
    label: normalizeText(pickFirstDefined(item, ['nombreEntidad', 'nombrePartner', 'nombreCliente', 'nombre'])),
    facturado: normalizeNumber(pickFirstDefined(item, ['totalFacturado', 'montoFacturado', 'facturado'])),
    cobrado: normalizeNumber(pickFirstDefined(item, ['totalCobrado', 'montoCobrado', 'cobrado'])),
    pendiente: normalizeNumber(pickFirstDefined(item, ['saldoPendiente', 'pendiente'])),
    porcentajeCobro: normalizeNumber(pickFirstDefined(item, ['porcentajeCobro'])),
  }));
}

export function mapWaterfallData(items = []) {
  return items.map((item, index) => {
    const type = buildWaterfallType(item.concepto);
    const rawValue = normalizeNumber(item.monto);

    return {
      id: index + 1,
      label: buildWaterfallLabel(item.concepto),
      value: rawValue,
      type,
    };
  });
}

export function mapRiesgoFinancieroData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: normalizeText(item.nombrePartner),
    value: normalizeNumber(item.saldoPendiente),
    risk: inferRiskLevel(item),
    diasMoraPromedio: normalizeNumber(item.diasMoraPromedio),
  }));
}

const DAY_NAME_TO_INDEX = {
  LUNES: 0, LUN: 0, MONDAY: 0, MON: 0,
  MARTES: 1, MAR: 1, TUESDAY: 1, TUE: 1,
  MIÉRCOLES: 2, MIERCOLES: 2, MIÉ: 2, MIE: 2, WEDNESDAY: 2, WED: 2,
  JUEVES: 3, JUE: 3, THURSDAY: 3, THU: 3,
  VIERNES: 4, VIE: 4, FRIDAY: 4, FRI: 4,
  SÁBADO: 5, SABADO: 5, SÁB: 5, SAB: 5, SATURDAY: 5, SAT: 5,
  DOMINGO: 6, DOM: 6, SUNDAY: 6, SUN: 6,
};

function resolveDayIndex(raw) {
  if (raw === null || raw === undefined) return 0;
  const num = Number(raw);
  if (Number.isFinite(num) && num >= 1 && num <= 7) return num - 1;
  const key = String(raw).trim().toUpperCase();
  return DAY_NAME_TO_INDEX[key] ?? 0;
}

export function mapHeatmapData(items = []) {
  const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  const hours = Array.from({ length: 24 }, (_, index) => index);
  const matrix = days.map(() => hours.map(() => 0));

  items.forEach((item) => {
    const dayIndex = resolveDayIndex(pickFirstDefined(item, ['numDiaSemana', 'diaSemana']));
    const hour = Math.max(0, Math.min(23, normalizeNumber(pickFirstDefined(item, ['hora', 'hour']), 0)));
    matrix[dayIndex][hour] = normalizeNumber(pickFirstDefined(item, ['volumenLlamadas', 'cantidad', 'valor']), 0);
  });

  return {
    matrix,
    xLabels: hours.map((hour) => `${String(hour).padStart(2, '0')}h`),
    yLabels: days,
  };
}

export function mapCalidadLlamadasFunnel(items = []) {
  const totals = items.reduce((accumulator, item) => {
    accumulator.total += normalizeNumber(item.totalLlamadas);
    accumulator.contestadas += normalizeNumber(item.contestadas);
    accumulator.perdidas += normalizeNumber(item.perdidas);
    accumulator.abandonadas += normalizeNumber(item.abandonadas);
    return accumulator;
  }, { total: 0, contestadas: 0, perdidas: 0, abandonadas: 0 });

  if (!totals.total) return [];

  const toRate = (value) => (totals.total ? (value / totals.total) * 100 : 0);

  return [
    { label: 'Intentos', count: totals.total, rate: 100 },
    { label: 'Contestadas', count: totals.contestadas, rate: toRate(totals.contestadas) },
    { label: 'Perdidas', count: totals.perdidas, rate: toRate(totals.perdidas) },
    { label: 'Abandonadas', count: totals.abandonadas, rate: toRate(totals.abandonadas) },
  ];
}

export function mapCalidadLlamadasDonut(items = []) {
  const totals = items.reduce((accumulator, item) => {
    accumulator.contestadas += normalizeNumber(item.contestadas);
    accumulator.perdidas += normalizeNumber(item.perdidas);
    return accumulator;
  }, { contestadas: 0, perdidas: 0 });

  return {
    contestadas: totals.contestadas,
    noContestadas: totals.perdidas,
  };
}

export function mapSaludMensajeriaData(items = []) {
  return items.map((item, index) => {
    const totalMensajes = normalizeNumber(item.totalMensajes);

    // Backend R6 (Enreach) sends 'entregados' as count.
    // Backend R15 (Partner) sends 'tasaEntrega' as rate — derive count.
    let entregados = normalizeNumber(item.entregados);
    if (entregados === 0 && totalMensajes > 0) {
      const tasaEntrega = normalizeNumber(item.tasaEntrega);
      if (tasaEntrega > 0) {
        entregados = Math.round((tasaEntrega / 100) * totalMensajes);
      }
    }

    // Backend R6 has no 'respuestas'. R15 has 'tasaRespuesta' — derive count.
    let respuestas = normalizeNumber(item.respuestas);
    if (respuestas === 0 && totalMensajes > 0) {
      const tasaRespuesta = normalizeNumber(item.tasaRespuesta);
      if (tasaRespuesta > 0) {
        respuestas = Math.round((tasaRespuesta / 100) * totalMensajes);
      }
    }

    const noEntregados = Math.max(totalMensajes - entregados, 0);

    return {
      id: index + 1,
      label: normalizeText(pickFirstDefined(item, ['nombrePartner', 'nombreCliente', 'nombreEntidad', 'plataformaOrigen', 'tipoContenido', 'dimension'])),
      totalMensajes,
      entregados,
      respuestas,
      noEntregados,
      mensajesGrupo: normalizeNumber(item.mensajesGrupo),
      mensajesDirectos: normalizeNumber(pickFirstDefined(item, ['mensajesDirectos', 'mensajesDirecto'])),
    };
  });
}

export function getSaludMensajeriaCategories() {
  return [
    { key: 'entregados', label: 'Entregados' },
    { key: 'respuestas', label: 'Respuestas' },
    { key: 'noEntregados', label: 'No entregados', color: 'var(--color-status-critical)' },
  ];
}

export function mapBoxPlotData(items = []) {
  // Group items by partner and compute aggregate statistics per partner.
  const grouped = new Map();

  items.forEach((item) => {
    const label = normalizeText(pickFirstDefined(item, ['nombrePartner', 'nombre']));
    if (!grouped.has(label)) grouped.set(label, []);

    const promedio = normalizeNumber(pickFirstDefined(item, ['esperaPromedio']));
    const p95 = normalizeNumber(pickFirstDefined(item, ['esperaPercentil95', 'p95EsperaSeg', 'p95']));
    const maxVal = normalizeNumber(pickFirstDefined(item, ['esperaMaxima', 'maxEsperaSeg', 'maxEsperaSegundos', 'maximo']));

    grouped.get(label).push({ promedio, p95, max: maxVal });
  });

  return Array.from(grouped.entries())
    .map(([label, values], index) => {
      const sorted = values.map((v) => v.promedio).filter((v) => v > 0).sort((a, b) => a - b);
      const allP95 = values.map((v) => v.p95).filter((v) => v > 0).sort((a, b) => a - b);
      const allMax = values.map((v) => v.max).filter((v) => v > 0);

      const percentile = (arr, pct) => {
        if (!arr.length) return 0;
        const idx = Math.ceil((pct / 100) * arr.length) - 1;
        return arr[Math.max(0, Math.min(idx, arr.length - 1))];
      };

      const min = sorted.length ? sorted[0] : 0;
      const p25 = percentile(sorted, 25);
      const median = percentile(sorted, 50);
      const p75 = percentile(sorted, 75);
      const p95 = allP95.length ? percentile(allP95, 95) : percentile(sorted, 95);
      const max = allMax.length ? Math.max(...allMax) : (sorted.length ? sorted[sorted.length - 1] : 0);

      return { id: index + 1, label, min, p25, median, p75, p95, max };
    })
    .sort((a, b) => b.p95 - a.p95)
    .slice(0, 8);
}

export function mapAgingCarteraData(items = []) {
  const order = ['0-30 dias', '31-60 dias', '61-90 dias', '> 90 dias'];
  const grouped = new Map();

  items.forEach((item) => {
    const label = normalizeText(item.nombreCliente);
    const key = normalizeText(item.rangoDias, 'sin_rango').toLowerCase();

    if (!grouped.has(label)) grouped.set(label, { label });
    grouped.get(label)[key] = normalizeNumber(pickFirstDefined(item, ['saldoPendiente', 'saldo']));
  });

  return Array.from(grouped.values()).map((row) => {
    order.forEach((bucket) => {
      const key = bucket.toLowerCase();
      if (!Object.hasOwn(row, key)) row[key] = 0;
    });
    return row;
  });
}

export function getAgingCategories() {
  return [
    { key: '0-30 dias', label: '0-30 días' },
    { key: '31-60 dias', label: '31-60 días' },
    { key: '61-90 dias', label: '61-90 días' },
    { key: '> 90 dias', label: '> 90 días', color: 'var(--color-status-critical)' },
  ];
}

export function mapPartnerUsoVsPlanBullets(items = []) {
  return items
    .map((item, index) => {
      // Backend sends absolute values; compute percentages.
      const minutosConsumo = normalizeNumber(item.minutosConsumidos);
      const minutosIncluidos = normalizeNumber(item.minutosIncluidos);
      const mensajesConsumo = normalizeNumber(item.mensajesConsumidos);
      const mensajesIncluidos = normalizeNumber(item.mensajesIncluidos);

      const minutosPct = normalizeNumber(item.usoMinutosPct)
        || (minutosIncluidos > 0 ? (minutosConsumo / minutosIncluidos) * 100 : 0);
      const mensajesPct = normalizeNumber(item.usoMensajesPct)
        || (mensajesIncluidos > 0 ? (mensajesConsumo / mensajesIncluidos) * 100 : 0);

      return {
        id: index + 1,
        label: normalizeText(pickFirstDefined(item, ['nombreCliente', 'nombrePlan'])),
        actual: Math.max(minutosPct, mensajesPct),
        target: 100,
        minutosPct,
        mensajesPct,
      };
    })
    .sort((left, right) => right.actual - left.actual)
    .slice(0, 4);
}

export function mapSlaBulletData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: normalizeText(pickFirstDefined(item, ['nombreCliente', 'nombreCola'])),
    actual: normalizeNumber(pickFirstDefined(item, ['esperaPercentil95', 'esperaPromedio'])),
    target: normalizeNumber(pickFirstDefined(item, ['maxEsperaPermitida'])),
    status: getRiskLevel(pickFirstDefined(item, ['estadoSLA'], 'Cumple')),
    cumplimientoSLA: pickFirstDefined(item, ['cumplimientoSLA'], false),
  }));
}

export function mapDeterioroLlamadasData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: normalizeText(item.nombreCliente),
    value: normalizeNumber(item.totalLlamadas),
    variation: normalizeNumber(item.tasaPerdida),
    tasaAbandono: normalizeNumber(item.tasaAbandono),
  }));
}

const MONTH_LABELS = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

function resolveMonthLabel(item) {
  const nombreMes = pickFirstDefined(item, ['nombreMes']);
  if (nombreMes) return normalizeText(nombreMes);
  const mes = normalizeNumber(item.mes);
  return mes >= 1 && mes <= 12 ? MONTH_LABELS[mes - 1] : `Mes ${mes}`;
}

export function mapGastoMensualData(items = []) {
  const sorted = [...items].sort((left, right) => {
    const yearDiff = normalizeNumber(left.anio) - normalizeNumber(right.anio);
    if (yearDiff !== 0) return yearDiff;
    return normalizeNumber(left.mes) - normalizeNumber(right.mes);
  });

  return sorted.map((item, index) => ({
    id: index + 1,
    label: resolveMonthLabel(item),
    actual: normalizeNumber(pickFirstDefined(item, ['gastoActual'])),
    reference: normalizeNumber(pickFirstDefined(item, ['promedioHistorico'])),
    desviacionPct: normalizeNumber(item.desviacionPct),
  }));
}

export function mapGastoFilialPlanData(items = []) {
  return items
    .map((item, index) => ({
      id: index + 1,
      label: `${normalizeText(item.nombreFilial)} · ${normalizeText(item.nombrePlan)}`,
      gasto: normalizeNumber(item.totalGasto),
    }))
    .sort((left, right) => right.gasto - left.gasto)
    .slice(0, 6);
}

export function mapUsoVsCapacidadSummary(items = []) {
  const totals = items.reduce((accumulator, item) => {
    accumulator.minutosConsumidos += normalizeNumber(item.minutosConsumidos);
    accumulator.minutosCapacidad += normalizeNumber(pickFirstDefined(item, ['minutosIncluidos', 'minutosCapacidad']));
    accumulator.mensajesConsumidos += normalizeNumber(item.mensajesConsumidos);
    accumulator.mensajesCapacidad += normalizeNumber(pickFirstDefined(item, ['mensajesIncluidos', 'mensajesCapacidad']));
    return accumulator;
  }, {
    minutosConsumidos: 0,
    minutosCapacidad: 0,
    mensajesConsumidos: 0,
    mensajesCapacidad: 0,
  });

  return [
    {
      id: 'minutos',
      label: 'Minutos',
      actual: totals.minutosConsumidos,
      target: totals.minutosCapacidad,
      unit: 'number',
    },
    {
      id: 'mensajes',
      label: 'Mensajes',
      actual: totals.mensajesConsumidos,
      target: totals.mensajesCapacidad,
      unit: 'number',
    },
  ];
}

export function mapUsuariosNoContestacionBarData(items = []) {
  return items
    .map((item, index) => ({
      id: index + 1,
      label: normalizeText(pickFirstDefined(item, ['nombreUsuario', 'numeroDid'])),
      primary: normalizeNumber(item.totalLlamadas),
      secondary: normalizeNumber(item.noContestadas),
      tasaNoContestacion: normalizeNumber(item.tasaNoContestacion),
    }))
    .sort((left, right) => right.secondary - left.secondary)
    .slice(0, 6);
}

export function mapGruposMensajeriaScatterData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: normalizeText(item.nombreGrupo),
    x: normalizeNumber(item.volumenMensajes),
    y: normalizeNumber(item.tasaEntrega),
    z: Math.max(normalizeNumber(item.tasaRespuesta), 1),
  }));
}

// ── MAPPERS NUEVOS ──────────────────────────────────────────────────────────

export function mapTendenciaFacturacionData(items = []) {
  const partners = [...new Set(items.map((i) => normalizeText(i.nombrePartner)))];
  const years = [...new Set(items.map((i) => normalizeNumber(i.anioReporte)))].sort();

  return years.map((anio) => {
    const row = { label: String(anio) };
    partners.forEach((p) => {
      const match = items.find((i) => normalizeText(i.nombrePartner) === p && normalizeNumber(i.anioReporte) === anio);
      row[p] = match ? normalizeNumber(match.totalFacturado) : 0;
    });
    return row;
  });
}

export function getTendenciaFacturacionCategories(items = []) {
  const partners = [...new Set(items.map((i) => normalizeText(i.nombrePartner)))];
  return partners.map((p, i) => ({
    key: p,
    label: p,
  }));
}

export function mapRevenuePorPaisData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: normalizeText(item.paisPartner),
    facturado: normalizeNumber(item.totalFacturado),
    pendiente: normalizeNumber(item.saldoPendiente),
    clientes: normalizeNumber(item.totalClientes),
  }));
}

export function mapCrecimientoNetoData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: `${item.anioReporte}-T${item.trimestreReporte}`,
    altas: normalizeNumber(item.altas),
    bajas: -Math.abs(normalizeNumber(item.bajas)),
    neto: normalizeNumber(item.neto),
  }));
}

export function mapTendenciaComunicacionesData(items = []) {
  const MONTH_LABELS = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  return items.map((item, index) => ({
    id: index + 1,
    label: `${MONTH_LABELS[(normalizeNumber(item.mesReporte) - 1)] || 'Mes'} ${item.anioReporte}`,
    shortLabel: MONTH_LABELS[(normalizeNumber(item.mesReporte) - 1)] || `M${item.mesReporte}`,
    anio: normalizeNumber(item.anioReporte),
    mes: normalizeNumber(item.mesReporte),
    llamadas: normalizeNumber(item.totalLlamadas),
    mensajes: normalizeNumber(item.totalMensajes),
    minutos: normalizeNumber(item.totalMinutos),
  }));
}

export function mapCostoPorInteraccionData(items = []) {
  const MONTH_LABELS = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  return items.map((item, index) => ({
    id: index + 1,
    label: MONTH_LABELS[(normalizeNumber(item.mesReporte) - 1)] || `M${item.mesReporte}`,
    actual: normalizeNumber(item.costoPorInteraccion),
    reference: normalizeNumber(item.promedioMovil3m),
  }));
}

export function mapEmbudoContactoFilialData(items = []) {
  return items.map((item, index) => ({
    id: index + 1,
    label: normalizeText(item.nombreFilial),
    intentos: normalizeNumber(item.intentosTotales),
    logrados: normalizeNumber(item.logrados),
    fallidos: normalizeNumber(item.fallidos),
    efectividad: normalizeNumber(item.pctEfectividad),
  }));
}
