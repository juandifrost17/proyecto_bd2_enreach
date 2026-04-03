-- ============================================================================
-- DASHBOARD ENREACH - KPIs SUPERIORES
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_kpi_enreach_1_facturacion_total_partners(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalFacturado NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS totalFacturado
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_enreach_2_cobro_total_partners(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalCobrado NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC AS totalCobrado
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_enreach_3_saldo_pendiente_total(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    saldoPendienteTotal NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendienteTotal
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_enreach_4_partners_activos(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    partnersActivos INT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT dp.id_partner)::INT AS partnersActivos
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_enreach_5_tasa_global_contestacion(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    tasaContestacion NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fl.es_contestada THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaContestacion
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fl.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_enreach_6_tasa_global_entrega_mensajes(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    tasaEntregaMensajes NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaEntregaMensajes
    FROM fact_mensaje fm
    JOIN dim_tiempo d
        ON fm.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fm.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_1_facturado_vs_cobrado(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner VARCHAR,
    totalFacturado NUMERIC,
    totalCobrado NUMERIC,
    saldoPendiente NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT 
        dp.nombre_partner::VARCHAR AS nombrePartner,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS totalFacturado,
        COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC AS totalCobrado,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendiente
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.nombre_partner
    ORDER BY totalFacturado DESC, nombrePartner ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_2_waterfall_monetizacion(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    concepto VARCHAR,
    monto NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        'Subtotal'::VARCHAR AS concepto,
        COALESCE(SUM(ff.subtotal), 0)::NUMERIC AS monto
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)

    UNION ALL

    SELECT
        'Descuento'::VARCHAR,
        COALESCE(SUM(ff.descuento), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)

    UNION ALL

    SELECT
        'Impuesto'::VARCHAR,
        COALESCE(SUM(ff.impuesto_monto), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)

    UNION ALL

    SELECT
        'Total Factura'::VARCHAR,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)

    UNION ALL

    SELECT
        'Total Pagado'::VARCHAR,
        COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)

    UNION ALL

    SELECT
        'Saldo Pendiente'::VARCHAR,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad);
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_3_riesgo_financiero(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner VARCHAR,
    saldoPendiente NUMERIC,
    diasMoraPromedio NUMERIC,
    contratosActivos INT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR AS nombrePartner,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendiente,
        COALESCE(AVG(ff.dias_mora), 0)::NUMERIC AS diasMoraPromedio,
        COUNT(
            DISTINCT CASE
                WHEN COALESCE(ff.sk_acuerdo, 0) <> 0 THEN ff.sk_acuerdo
                ELSE NULL
            END
        )::INT AS contratosActivos
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
      AND COALESCE(ff.saldo_pendiente, 0) > 0
    GROUP BY dp.nombre_partner
    ORDER BY saldoPendiente DESC, nombrePartner ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_4_demanda_horaria_voz(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    diaSemana VARCHAR,
    hora INT,
    volumenLlamadas BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        d.dia_semana::VARCHAR AS diaSemana,
        d.hora::INT AS hora,
        COUNT(*)::BIGINT AS volumenLlamadas
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON d.sk_tiempo = fl.sk_tiempo
    JOIN dim_partner dp
        ON dp.sk_partner = fl.sk_partner
    WHERE d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY d.dia_semana, d.num_dia_semana, d.hora
    ORDER BY d.num_dia_semana, d.hora;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_5_calidad_llamadas_partner(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner VARCHAR,
    totalLlamadas BIGINT,
    contestadas BIGINT,
    perdidas BIGINT,
    abandonadas BIGINT,
    tasaContestacion NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR AS nombrePartner,
        COUNT(*)::BIGINT AS totalLlamadas,
        SUM(CASE WHEN fl.es_contestada THEN 1 ELSE 0 END)::BIGINT AS contestadas,
        SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END)::BIGINT AS perdidas,
        SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END)::BIGINT AS abandonadas,
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fl.es_contestada THEN 1 ELSE 0 END) * 100.0)
                / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaContestacion
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fl.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.nombre_partner
    ORDER BY totalLlamadas DESC, nombrePartner ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_6_salud_mensajeria_partner(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner VARCHAR,
    totalMensajes BIGINT,
    entregados BIGINT,
    tasaEntrega NUMERIC,
    mensajesGrupo BIGINT,
    mensajesDirecto BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR AS nombrePartner,
        COUNT(*)::BIGINT AS totalMensajes,
        SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END)::BIGINT AS entregados,
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0)
                / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaEntrega,
        SUM(CASE WHEN fm.es_grupo THEN 1 ELSE 0 END)::BIGINT AS mensajesGrupo,
        SUM(CASE WHEN COALESCE(fm.es_grupo, FALSE) = FALSE THEN 1 ELSE 0 END)::BIGINT AS mensajesDirecto
    FROM fact_mensaje fm
    JOIN dim_tiempo d
        ON fm.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fm.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.nombre_partner
    ORDER BY totalMensajes DESC, nombrePartner ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_7_variabilidad_espera(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner VARCHAR,
    nombreCola VARCHAR,
    maxEsperaSegundos INT,
    esperaPromedio NUMERIC,
    esperaMaxima NUMERIC,
    esperaPercentil95 NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR AS nombrePartner,
        dc.nombre::VARCHAR AS nombreCola,
        COALESCE(dc.max_espera_segundos, 0)::INT AS maxEsperaSegundos,
        COALESCE(AVG(fl.tiempo_espera_seg), 0)::NUMERIC AS esperaPromedio,
        COALESCE(MAX(fl.tiempo_espera_seg), 0)::NUMERIC AS esperaMaxima,
        COALESCE(
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fl.tiempo_espera_seg),
            0
        )::NUMERIC AS esperaPercentil95
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON d.sk_tiempo = fl.sk_tiempo
    JOIN dim_partner dp
        ON dp.sk_partner = fl.sk_partner
    JOIN dim_cola dc
        ON dc.sk_cola = fl.sk_cola
    WHERE d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
      AND fl.tiempo_espera_seg IS NOT NULL
    GROUP BY dp.nombre_partner, dc.nombre, dc.max_espera_segundos
    ORDER BY esperaPromedio DESC, nombrePartner ASC, nombreCola ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_8_scorecard_partners(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner VARCHAR,
    revenue NUMERIC,
    saldoPendiente NUMERIC,
    diasMora INT,
    tasaPerdida NUMERIC,
    tasaAbandono NUMERIC,
    tasaEntregaMensajes NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH ff_agg AS (
        SELECT
            ff.sk_partner,
            COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS revenue,
            COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendiente,
            COALESCE(MAX(ff.dias_mora), 0)::INT AS diasMora
        FROM fact_facturacion ff
        JOIN dim_tiempo d
            ON d.sk_tiempo = ff.sk_fecha_emision
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY ff.sk_partner
    ),
    fl_agg AS (
        SELECT
            fl.sk_partner,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) * 100.0)
                    / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasaPerdida,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END) * 100.0)
                    / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasaAbandono
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON d.sk_tiempo = fl.sk_tiempo
        WHERE d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_partner
    ),
    fm_agg AS (
        SELECT
            fm.sk_partner,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0)
                    / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasaEntregaMensajes
        FROM fact_mensaje fm
        JOIN dim_tiempo d
            ON d.sk_tiempo = fm.sk_tiempo
        WHERE d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fm.sk_partner
    )
    SELECT
        dp.nombre_partner::VARCHAR AS nombrePartner,
        COALESCE(ff_agg.revenue, 0)::NUMERIC AS revenue,
        COALESCE(ff_agg.saldoPendiente, 0)::NUMERIC AS saldoPendiente,
        COALESCE(ff_agg.diasMora, 0)::INT AS diasMora,
        COALESCE(fl_agg.tasaPerdida, 0)::NUMERIC AS tasaPerdida,
        COALESCE(fl_agg.tasaAbandono, 0)::NUMERIC AS tasaAbandono,
        COALESCE(fm_agg.tasaEntregaMensajes, 0)::NUMERIC AS tasaEntregaMensajes
    FROM dim_partner dp
    LEFT JOIN ff_agg
        ON ff_agg.sk_partner = dp.sk_partner
    LEFT JOIN fl_agg
        ON fl_agg.sk_partner = dp.sk_partner
    LEFT JOIN fm_agg
        ON fm_agg.sk_partner = dp.sk_partner
    WHERE (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
      AND (
            ff_agg.sk_partner IS NOT NULL
         OR fl_agg.sk_partner IS NOT NULL
         OR fm_agg.sk_partner IS NOT NULL
      )
    ORDER BY revenue DESC, nombrePartner ASC;
END;
$$;

-- ============================================================================
-- DASHBOARD PARTNER - KPIs SUPERIORES
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_kpi_partner_1_facturacion_periodo(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalFacturado NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS totalFacturado
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_2_cobro_periodo(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalCobrado NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC AS totalCobrado
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_3_cartera_vencida(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    carteraVencida NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS carteraVencida
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND COALESCE(ff.saldo_pendiente, 0) > 0
      AND COALESCE(ff.dias_mora, 0) > 0;
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_4_clientes_activos(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    clientesActivos INT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT dc.id_cliente)::INT AS clientesActivos
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_5_uso_promedio_plan(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    usoPromedioPorcentaje NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH capacidad AS (
        SELECT
            COALESCE(SUM(dpp.minutos_incluidos * ff.cantidad), 0)::NUMERIC AS minutos_incluidos
        FROM fact_facturacion ff
        JOIN dim_tiempo d
            ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner dp
            ON ff.sk_partner = dp.sk_partner
        JOIN dim_plan_producto dpp
            ON ff.sk_plan = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
    ),
    consumo AS (
        SELECT
            COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS minutos_consumidos
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
    )
    SELECT
        COALESCE(
            ROUND(
                (consumo.minutos_consumidos * 100.0) / NULLIF(capacidad.minutos_incluidos, 0),
                2
            ),
            0
        )::NUMERIC AS usoPromedioPorcentaje
    FROM capacidad
    CROSS JOIN consumo;
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_6_tasa_entrega_mensajes(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    tasaEntrega NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaEntrega
    FROM fact_mensaje fm
    JOIN dim_tiempo d
        ON fm.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fm.sk_partner = dp.sk_partner
    WHERE dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


-- ============================================================================
-- DASHBOARD PARTNER - REPORTES (9 al 16)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_reporte_9_facturado_cobrado_cliente(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    totalFacturado NUMERIC,
    totalCobrado NUMERIC,
    saldoPendiente NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS totalFacturado,
        COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC AS totalCobrado,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendiente
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
    GROUP BY dc.razon_social
    ORDER BY totalFacturado DESC, nombreCliente ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_10_aging_cartera_cliente(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    rangoDias VARCHAR,
    saldoPendiente NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        CASE
            WHEN ff.dias_mora BETWEEN 0 AND 30 THEN '0-30 dias'
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN '31-60 dias'
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN '61-90 dias'
            ELSE '> 90 dias'
        END::VARCHAR AS rangoDias,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendiente
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp
        ON ff.sk_partner = dp.sk_partner
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND COALESCE(ff.saldo_pendiente, 0) > 0
    GROUP BY
        dc.razon_social,
        CASE
            WHEN ff.dias_mora BETWEEN 0 AND 30 THEN '0-30 dias'
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN '31-60 dias'
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN '61-90 dias'
            ELSE '> 90 dias'
        END
    ORDER BY nombreCliente ASC, rangoDias ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_11_uso_real_vs_plan(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    nombrePlan VARCHAR,
    minutosConsumidos NUMERIC,
    minutosIncluidos NUMERIC,
    mensajesConsumidos BIGINT,
    mensajesIncluidos BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH capacidad AS (
        SELECT
            ff.sk_cliente,
            ff.sk_plan,
            COALESCE(SUM(dpp.minutos_incluidos * ff.cantidad), 0)::NUMERIC AS minutos_incluidos,
            COALESCE(SUM(dpp.mensajes_incluidos * ff.cantidad), 0)::BIGINT AS mensajes_incluidos
        FROM fact_facturacion ff
        JOIN dim_tiempo d
            ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner dp
            ON ff.sk_partner = dp.sk_partner
        JOIN dim_plan_producto dpp
            ON ff.sk_plan = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY ff.sk_cliente, ff.sk_plan
    ),
    consumo_llamadas AS (
        SELECT
            fl.sk_cliente,
            fl.sk_plan,
            COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS minutos_consumidos
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_cliente, fl.sk_plan
    ),
    consumo_mensajes AS (
        SELECT
            fm.sk_cliente,
            fm.sk_plan,
            COUNT(*)::BIGINT AS mensajes_consumidos
        FROM fact_mensaje fm
        JOIN dim_tiempo d
            ON fm.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fm.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fm.sk_cliente, fm.sk_plan
    )
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        dpp.nombre_plan::VARCHAR AS nombrePlan,
        COALESCE(cl.minutos_consumidos, 0)::NUMERIC AS minutosConsumidos,
        COALESCE(cap.minutos_incluidos, 0)::NUMERIC AS minutosIncluidos,
        COALESCE(cm.mensajes_consumidos, 0)::BIGINT AS mensajesConsumidos,
        COALESCE(cap.mensajes_incluidos, 0)::BIGINT AS mensajesIncluidos
    FROM capacidad cap
    JOIN dim_cliente dc
        ON cap.sk_cliente = dc.sk_cliente
    JOIN dim_plan_producto dpp
        ON cap.sk_plan = dpp.sk_plan
    LEFT JOIN consumo_llamadas cl
        ON cap.sk_cliente = cl.sk_cliente
       AND cap.sk_plan = cl.sk_plan
    LEFT JOIN consumo_mensajes cm
        ON cap.sk_cliente = cm.sk_cliente
       AND cap.sk_plan = cm.sk_plan
    ORDER BY minutosConsumidos DESC, nombreCliente ASC, nombrePlan ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_12_riesgo_churn_cliente(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    volumenLlamadas BIGINT,
    tasaPerdida NUMERIC,
    tasaEntregaMensajes NUMERIC,
    indicadorRiesgo VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
    v_prev_anio INT;
    v_prev_periodo INT;
BEGIN
    IF v_tipo_filtro = 'M' THEN
        v_prev_anio := CASE WHEN p_periodo = 1 THEN p_anio - 1 ELSE p_anio END;
        v_prev_periodo := CASE WHEN p_periodo = 1 THEN 12 ELSE p_periodo - 1 END;
    ELSIF v_tipo_filtro = 'T' THEN
        v_prev_anio := CASE WHEN p_periodo = 1 THEN p_anio - 1 ELSE p_anio END;
        v_prev_periodo := CASE WHEN p_periodo = 1 THEN 4 ELSE p_periodo - 1 END;
    ELSE
        v_prev_anio := p_anio - 1;
        v_prev_periodo := NULL;
    END IF;

    RETURN QUERY
    WITH actual_ll AS (
        SELECT
            fl.sk_cliente,
            COUNT(*)::BIGINT AS total_ll,
            COALESCE(AVG(fl.tiempo_espera_seg), 0)::NUMERIC AS espera_prom,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasa_perdida
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_cliente
    ),
    previo_ll AS (
        SELECT
            fl.sk_cliente,
            COUNT(*)::BIGINT AS total_ll,
            COALESCE(AVG(fl.tiempo_espera_seg), 0)::NUMERIC AS espera_prom
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = v_prev_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = v_prev_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = v_prev_periodo)
          )
        GROUP BY fl.sk_cliente
    ),
    actual_msg AS (
        SELECT
            fm.sk_cliente,
            COUNT(*)::BIGINT AS total_msg,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasa_entrega
        FROM fact_mensaje fm
        JOIN dim_tiempo d
            ON fm.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fm.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fm.sk_cliente
    ),
    previo_msg AS (
        SELECT
            fm.sk_cliente,
            COUNT(*)::BIGINT AS total_msg,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasa_entrega
        FROM fact_mensaje fm
        JOIN dim_tiempo d
            ON fm.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fm.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = v_prev_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = v_prev_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = v_prev_periodo)
          )
        GROUP BY fm.sk_cliente
    ),
    clientes AS (
        SELECT sk_cliente FROM actual_ll
        UNION
        SELECT sk_cliente FROM previo_ll
        UNION
        SELECT sk_cliente FROM actual_msg
        UNION
        SELECT sk_cliente FROM previo_msg
    )
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        COALESCE(al.total_ll, 0)::BIGINT AS volumenLlamadas,
        COALESCE(al.tasa_perdida, 0)::NUMERIC AS tasaPerdida,
        COALESCE(am.tasa_entrega, 0)::NUMERIC AS tasaEntregaMensajes,
        CASE
            WHEN COALESCE(pl.total_ll, 0) = 0 AND COALESCE(pm.total_msg, 0) = 0 THEN 'SIN_BASE'
            WHEN (
                    COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 20
                 OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 20
                 OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 20
                 OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 5
                 )
                THEN 'ALTO'
            WHEN (
                    COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 10
                 OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 10
                 OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 10
                 OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 2
                 )
                THEN 'MEDIO'
            ELSE 'BAJO'
        END::VARCHAR AS indicadorRiesgo
    FROM clientes c
    JOIN dim_cliente dc
        ON c.sk_cliente = dc.sk_cliente
    LEFT JOIN actual_ll al
        ON c.sk_cliente = al.sk_cliente
    LEFT JOIN previo_ll pl
        ON c.sk_cliente = pl.sk_cliente
    LEFT JOIN actual_msg am
        ON c.sk_cliente = am.sk_cliente
    LEFT JOIN previo_msg pm
        ON c.sk_cliente = pm.sk_cliente
    ORDER BY
        CASE
            WHEN
                CASE
                    WHEN COALESCE(pl.total_ll, 0) = 0 AND COALESCE(pm.total_msg, 0) = 0 THEN 'SIN_BASE'
                    WHEN (
                            COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 20
                         OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 20
                         OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 20
                         OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 5
                         )
                        THEN 'ALTO'
                    WHEN (
                            COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 10
                         OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 10
                         OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 10
                         OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 2
                         )
                        THEN 'MEDIO'
                    ELSE 'BAJO'
                END = 'ALTO' THEN 1
            WHEN
                CASE
                    WHEN COALESCE(pl.total_ll, 0) = 0 AND COALESCE(pm.total_msg, 0) = 0 THEN 'SIN_BASE'
                    WHEN (
                            COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 20
                         OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 20
                         OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 20
                         OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 5
                         )
                        THEN 'ALTO'
                    WHEN (
                            COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 10
                         OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 10
                         OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 10
                         OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 2
                         )
                        THEN 'MEDIO'
                    ELSE 'BAJO'
                END = 'MEDIO' THEN 2
            WHEN
                CASE
                    WHEN COALESCE(pl.total_ll, 0) = 0 AND COALESCE(pm.total_msg, 0) = 0 THEN 'SIN_BASE'
                    WHEN (
                            COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 20
                         OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 20
                         OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 20
                         OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 5
                         )
                        THEN 'ALTO'
                    WHEN (
                            COALESCE(((pl.total_ll - COALESCE(al.total_ll, 0)) * 100.0) / NULLIF(pl.total_ll, 0), 0) >= 10
                         OR COALESCE(((pm.total_msg - COALESCE(am.total_msg, 0)) * 100.0) / NULLIF(pm.total_msg, 0), 0) >= 10
                         OR COALESCE(((COALESCE(al.espera_prom, 0) - pl.espera_prom) * 100.0) / NULLIF(pl.espera_prom, 0), 0) >= 10
                         OR COALESCE(pm.tasa_entrega - COALESCE(am.tasa_entrega, 0), 0) >= 2
                         )
                        THEN 'MEDIO'
                    ELSE 'BAJO'
                END = 'BAJO' THEN 3
            ELSE 4
        END,
        nombreCliente ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_13_cumplimiento_sla_cliente(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    nombreCola VARCHAR,
    esperaPromedio NUMERIC,
    maxEsperaPermitida NUMERIC,
    cumplimientoSLA BOOLEAN
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        dcola.nombre::VARCHAR AS nombreCola,
        COALESCE(AVG(fl.tiempo_espera_seg), 0)::NUMERIC AS esperaPromedio,
        COALESCE(MAX(dcola.max_espera_segundos), 0)::NUMERIC AS maxEsperaPermitida,
        CASE
            WHEN COALESCE(
                    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fl.tiempo_espera_seg),
                    0
                 ) <= COALESCE(MAX(dcola.max_espera_segundos), 0)
            THEN TRUE
            ELSE FALSE
        END AS cumplimientoSLA
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fl.sk_partner = dp.sk_partner
    JOIN dim_cliente dc
        ON fl.sk_cliente = dc.sk_cliente
    JOIN dim_cola dcola
        ON fl.sk_cola = dcola.sk_cola
    WHERE dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND fl.tiempo_espera_seg IS NOT NULL
    GROUP BY dc.razon_social, dcola.nombre, dcola.max_espera_segundos
    ORDER BY esperaPromedio DESC, nombreCliente ASC, nombreCola ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_14_deterioro_llamadas(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    totalLlamadas BIGINT,
    perdidas BIGINT,
    abandonadas BIGINT,
    tasaPerdida NUMERIC,
    tasaAbandono NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
    v_prev_anio INT;
    v_prev_periodo INT;
BEGIN
    IF v_tipo_filtro = 'M' THEN
        v_prev_anio := CASE WHEN p_periodo = 1 THEN p_anio - 1 ELSE p_anio END;
        v_prev_periodo := CASE WHEN p_periodo = 1 THEN 12 ELSE p_periodo - 1 END;
    ELSIF v_tipo_filtro = 'T' THEN
        v_prev_anio := CASE WHEN p_periodo = 1 THEN p_anio - 1 ELSE p_anio END;
        v_prev_periodo := CASE WHEN p_periodo = 1 THEN 4 ELSE p_periodo - 1 END;
    ELSE
        v_prev_anio := p_anio - 1;
        v_prev_periodo := NULL;
    END IF;

    RETURN QUERY
    WITH actual AS (
        SELECT
            fl.sk_cliente,
            COUNT(*)::BIGINT AS total_ll,
            SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END)::BIGINT AS perdidas,
            SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END)::BIGINT AS abandonadas,
            COALESCE(
                (SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                0
            )::NUMERIC AS tasa_perdida,
            COALESCE(
                (SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                0
            )::NUMERIC AS tasa_abandono
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_cliente
    ),
    previo AS (
        SELECT
            fl.sk_cliente,
            COALESCE(
                (SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                0
            )::NUMERIC AS tasa_perdida,
            COALESCE(
                (SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                0
            )::NUMERIC AS tasa_abandono
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = v_prev_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = v_prev_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = v_prev_periodo)
          )
        GROUP BY fl.sk_cliente
    )
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        COALESCE(a.total_ll, 0)::BIGINT AS totalLlamadas,
        COALESCE(a.perdidas, 0)::BIGINT AS perdidas,
        COALESCE(a.abandonadas, 0)::BIGINT AS abandonadas,
        COALESCE(a.tasa_perdida - p.tasa_perdida, a.tasa_perdida, 0)::NUMERIC AS tasaPerdida,
        COALESCE(a.tasa_abandono - p.tasa_abandono, a.tasa_abandono, 0)::NUMERIC AS tasaAbandono
    FROM actual a
    JOIN dim_cliente dc
        ON a.sk_cliente = dc.sk_cliente
    LEFT JOIN previo p
        ON a.sk_cliente = p.sk_cliente
    ORDER BY tasaPerdida DESC, tasaAbandono DESC, nombreCliente ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_15_calidad_mensajeria_cliente(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    totalMensajes BIGINT,
    tasaEntrega NUMERIC,
    tasaRespuesta NUMERIC,
    mensajesGrupo BIGINT,
    mensajesDirectos BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        COUNT(*)::BIGINT AS totalMensajes,
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaEntrega,
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.es_respuesta THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaRespuesta,
        SUM(CASE WHEN fm.es_grupo THEN 1 ELSE 0 END)::BIGINT AS mensajesGrupo,
        SUM(CASE WHEN COALESCE(fm.es_grupo, FALSE) = FALSE THEN 1 ELSE 0 END)::BIGINT AS mensajesDirectos
    FROM fact_mensaje fm
    JOIN dim_tiempo d
        ON fm.sk_tiempo = d.sk_tiempo
    JOIN dim_partner dp
        ON fm.sk_partner = dp.sk_partner
    JOIN dim_cliente dc
        ON fm.sk_cliente = dc.sk_cliente
    WHERE dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
    GROUP BY dc.razon_social
    ORDER BY totalMensajes DESC, nombreCliente ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_16_mesa_operativa_clientes(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente VARCHAR,
    saldoPendiente NUMERIC,
    diasMora INT,
    usoPlanPorcentaje NUMERIC,
    tasaPerdidaLlamadas NUMERIC,
    tasaEntregaMensajes NUMERIC,
    colaCritica VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH ff_agg AS (
        SELECT
            ff.sk_cliente,
            COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldo_pendiente,
            COALESCE(MAX(ff.dias_mora), 0)::INT AS dias_mora
        FROM fact_facturacion ff
        JOIN dim_tiempo d
            ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner dp
            ON ff.sk_partner = dp.sk_partner
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY ff.sk_cliente
    ),
    cap_agg AS (
        SELECT
            ff.sk_cliente,
            COALESCE(SUM(dpp.minutos_incluidos * ff.cantidad), 0)::NUMERIC AS minutos_incluidos
        FROM fact_facturacion ff
        JOIN dim_tiempo d
            ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner dp
            ON ff.sk_partner = dp.sk_partner
        JOIN dim_plan_producto dpp
            ON ff.sk_plan = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY ff.sk_cliente
    ),
    fl_agg AS (
        SELECT
            fl.sk_cliente,
            COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS minutos_consumidos,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasa_perdida
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_cliente
    ),
    fm_agg AS (
        SELECT
            fm.sk_cliente,
            COALESCE(
                ROUND(
                    (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                    2
                ),
                0
            )::NUMERIC AS tasa_entrega
        FROM fact_mensaje fm
        JOIN dim_tiempo d
            ON fm.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fm.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fm.sk_cliente
    ),
    cola_rank AS (
        SELECT
            fl.sk_cliente,
            dc.nombre::VARCHAR AS nombre_cola,
            ROW_NUMBER() OVER (
                PARTITION BY fl.sk_cliente
                ORDER BY AVG(fl.tiempo_espera_seg) DESC,
                         SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) DESC,
                         dc.nombre ASC
            ) AS rn
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_partner dp
            ON fl.sk_partner = dp.sk_partner
        JOIN dim_cola dc
            ON fl.sk_cola = dc.sk_cola
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_cliente, dc.nombre
    )
    SELECT
        dc.razon_social::VARCHAR AS nombreCliente,
        COALESCE(ff.saldo_pendiente, 0)::NUMERIC AS saldoPendiente,
        COALESCE(ff.dias_mora, 0)::INT AS diasMora,
        COALESCE(
            ROUND(
                (COALESCE(fl.minutos_consumidos, 0) * 100.0) / NULLIF(cap.minutos_incluidos, 0),
                2
            ),
            0
        )::NUMERIC AS usoPlanPorcentaje,
        COALESCE(fl.tasa_perdida, 0)::NUMERIC AS tasaPerdidaLlamadas,
        COALESCE(fm.tasa_entrega, 0)::NUMERIC AS tasaEntregaMensajes,
        COALESCE(cr.nombre_cola, 'SIN_COLA')::VARCHAR AS colaCritica
    FROM ff_agg ff
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    LEFT JOIN cap_agg cap
        ON ff.sk_cliente = cap.sk_cliente
    LEFT JOIN fl_agg fl
        ON ff.sk_cliente = fl.sk_cliente
    LEFT JOIN fm_agg fm
        ON ff.sk_cliente = fm.sk_cliente
    LEFT JOIN cola_rank cr
        ON ff.sk_cliente = cr.sk_cliente
       AND cr.rn = 1
    WHERE COALESCE(ff.saldo_pendiente, 0) > 0
       OR COALESCE(fl.tasa_perdida, 0) > 10
    ORDER BY saldoPendiente DESC, nombreCliente ASC;
END;
$$;

-- ============================================================================
-- DASHBOARD CLIENTE / TENANT - KPIs SUPERIORES
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_kpi_cliente_1_gasto_periodo(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalGasto NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS totalGasto
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_2_monto_pagado(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalPagado NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC AS totalPagado
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_3_saldo_pendiente(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    saldoPendiente NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldoPendiente
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_4_uso_minutos(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalMinutos NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS totalMinutos
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_cliente dc
        ON fl.sk_cliente = dc.sk_cliente
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_5_uso_mensajes(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    totalMensajes BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COUNT(*)::BIGINT AS totalMensajes
    FROM fact_mensaje fm
    JOIN dim_tiempo d
        ON fm.sk_tiempo = d.sk_tiempo
    JOIN dim_cliente dc
        ON fm.sk_cliente = dc.sk_cliente
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      );
END;
$$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_6_colas_fuera_sla(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    colasFueraSLA INT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH cola_sla AS (
        SELECT
            fl.sk_cola,
            AVG(fl.tiempo_espera_seg)::NUMERIC AS espera_promedio,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fl.tiempo_espera_seg)::NUMERIC AS espera_p95,
            MAX(dc.max_espera_segundos)::NUMERIC AS max_espera
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_cliente cli
            ON fl.sk_cliente = cli.sk_cliente
        JOIN dim_cola dc
            ON fl.sk_cola = dc.sk_cola
        WHERE cli.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
          AND fl.sk_cola IS NOT NULL
          AND fl.tiempo_espera_seg IS NOT NULL
        GROUP BY fl.sk_cola
    )
    SELECT COUNT(*)::INT AS colasFueraSLA
    FROM cola_sla
    WHERE espera_promedio > max_espera
       OR espera_p95 > max_espera;
END;
$$;


-- ============================================================================
-- DASHBOARD CLIENTE / TENANT - REPORTES (17 al 24)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_reporte_17_gasto_vs_promedio(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    mes INT,
    gastoActual NUMERIC,
    promedioHistorico NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH meses AS (
        SELECT generate_series(
            (MAKE_DATE(p_anio, 1, 1) - INTERVAL '5 months')::DATE,
            MAKE_DATE(p_anio, 12, 1)::DATE,
            INTERVAL '1 month'
        )::DATE AS mes_ref
    ),
    gasto_mensual AS (
        SELECT
            m.mes_ref,
            COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS gasto_actual
        FROM meses m
        LEFT JOIN dim_tiempo d
            ON d.anio = EXTRACT(YEAR FROM m.mes_ref)::INT
           AND d.mes = EXTRACT(MONTH FROM m.mes_ref)::INT
        LEFT JOIN fact_facturacion ff
            ON ff.sk_fecha_emision = d.sk_tiempo
        LEFT JOIN dim_cliente dc
            ON ff.sk_cliente = dc.sk_cliente
        WHERE (dc.id_cliente = p_id_entidad OR dc.id_cliente IS NULL)
          AND (
                UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
             OR ff.tipo_facturacion IS NULL
          )
        GROUP BY m.mes_ref
    ),
    serie AS (
        SELECT
            mes_ref,
            gasto_actual,
            AVG(gasto_actual) OVER (
                ORDER BY mes_ref
                ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
            )::NUMERIC AS promedio_historico
        FROM gasto_mensual
    )
    SELECT
        EXTRACT(MONTH FROM s.mes_ref)::INT AS mes,
        s.gasto_actual::NUMERIC AS gastoActual,
        COALESCE(ROUND(s.promedio_historico, 2), 0)::NUMERIC AS promedioHistorico
    FROM serie s
    WHERE EXTRACT(YEAR FROM s.mes_ref)::INT = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND EXTRACT(MONTH FROM s.mes_ref)::INT = p_periodo)
         OR (v_tipo_filtro = 'T' AND EXTRACT(QUARTER FROM s.mes_ref)::INT = p_periodo)
      )
    ORDER BY mes;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_18_gasto_por_filial_plan(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreFilial VARCHAR,
    nombrePlan VARCHAR,
    totalGasto NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.nombre_filial::VARCHAR AS nombreFilial,
        dpp.nombre_plan::VARCHAR AS nombrePlan,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS totalGasto
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    JOIN dim_plan_producto dpp
        ON ff.sk_plan = dpp.sk_plan
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
    GROUP BY dc.nombre_filial, dpp.nombre_plan
    ORDER BY totalGasto DESC, nombreFilial ASC, nombrePlan ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_19_estado_pagos_facturas(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    idFactura INT,
    fechaEmision DATE,
    nombrePlan VARCHAR,
    estadoFactura VARCHAR,
    metodoPago VARCHAR,
    montoTotal NUMERIC,
    montoPagado NUMERIC,
    saldoPendiente NUMERIC,
    diasMora INT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        ff.id_factura::INT AS idFactura,
        d.fecha::DATE AS fechaEmision,
        dpp.nombre_plan::VARCHAR AS nombrePlan,
        dep.estado_factura::VARCHAR AS estadoFactura,
        dep.metodo_pago::VARCHAR AS metodoPago,
        COALESCE(ff.monto_total_factura, 0)::NUMERIC AS montoTotal,
        COALESCE(ff.monto_pagado, 0)::NUMERIC AS montoPagado,
        COALESCE(ff.saldo_pendiente, 0)::NUMERIC AS saldoPendiente,
        COALESCE(ff.dias_mora, 0)::INT AS diasMora
    FROM fact_facturacion ff
    JOIN dim_tiempo d
        ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc
        ON ff.sk_cliente = dc.sk_cliente
    LEFT JOIN dim_plan_producto dpp
        ON ff.sk_plan = dpp.sk_plan
    LEFT JOIN dim_estado_pago dep
        ON ff.sk_estado_pago = dep.sk_estado_pago
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
    ORDER BY d.fecha DESC, ff.id_factura DESC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_20_uso_vs_capacidad(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreFilial VARCHAR,
    minutosConsumidos NUMERIC,
    minutosCapacidad NUMERIC,
    mensajesConsumidos BIGINT,
    mensajesCapacidad BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH capacidad AS (
        SELECT
            ff.sk_cliente,
            COALESCE(SUM(dpp.minutos_incluidos * ff.cantidad), 0)::NUMERIC AS minutos_capacidad,
            COALESCE(SUM(dpp.mensajes_incluidos * ff.cantidad), 0)::BIGINT AS mensajes_capacidad
        FROM fact_facturacion ff
        JOIN dim_tiempo d
            ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_cliente dc
            ON ff.sk_cliente = dc.sk_cliente
        JOIN dim_plan_producto dpp
            ON ff.sk_plan = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY ff.sk_cliente
    ),
    consumo_llamadas AS (
        SELECT
            fl.sk_cliente,
            COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS minutos_consumidos
        FROM fact_llamada fl
        JOIN dim_tiempo d
            ON fl.sk_tiempo = d.sk_tiempo
        JOIN dim_cliente dc
            ON fl.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fl.sk_cliente
    ),
    consumo_mensajes AS (
        SELECT
            fm.sk_cliente,
            COUNT(*)::BIGINT AS mensajes_consumidos
        FROM fact_mensaje fm
        JOIN dim_tiempo d
            ON fm.sk_tiempo = d.sk_tiempo
        JOIN dim_cliente dc
            ON fm.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (
                v_tipo_filtro = 'A'
             OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
             OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
          )
        GROUP BY fm.sk_cliente
    )
    SELECT
        dc.nombre_filial::VARCHAR AS nombreFilial,
        COALESCE(cl.minutos_consumidos, 0)::NUMERIC AS minutosConsumidos,
        COALESCE(cap.minutos_capacidad, 0)::NUMERIC AS minutosCapacidad,
        COALESCE(cm.mensajes_consumidos, 0)::BIGINT AS mensajesConsumidos,
        COALESCE(cap.mensajes_capacidad, 0)::BIGINT AS mensajesCapacidad
    FROM capacidad cap
    JOIN dim_cliente dc
        ON cap.sk_cliente = dc.sk_cliente
    LEFT JOIN consumo_llamadas cl
        ON cap.sk_cliente = cl.sk_cliente
    LEFT JOIN consumo_mensajes cm
        ON cap.sk_cliente = cm.sk_cliente
    ORDER BY minutosConsumidos DESC, nombreFilial ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_21_saturacion_horaria(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreFilial VARCHAR,
    nombreCola VARCHAR,
    diaSemana VARCHAR,
    hora INT,
    volumenLlamadas BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.nombre_filial::VARCHAR AS nombreFilial,
        dcola.nombre::VARCHAR AS nombreCola,
        d.dia_semana::VARCHAR AS diaSemana,
        d.hora::INT AS hora,
        COUNT(*)::BIGINT AS volumenLlamadas
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_cliente dc
        ON fl.sk_cliente = dc.sk_cliente
    JOIN dim_cola dcola
        ON fl.sk_cola = dcola.sk_cola
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
    GROUP BY dc.nombre_filial, dcola.nombre, d.dia_semana, d.num_dia_semana, d.hora
    ORDER BY d.num_dia_semana, d.hora, volumenLlamadas DESC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_22_usuarios_no_contestacion(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreUsuario VARCHAR,
    numeroDid VARCHAR,
    totalLlamadas BIGINT,
    noContestadas BIGINT,
    tasaNoContestacion NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        (du.nombre || ' ' || du.apellido)::VARCHAR AS nombreUsuario,
        du.numero_did::VARCHAR AS numeroDid,
        COUNT(*)::BIGINT AS totalLlamadas,
        SUM(
            CASE
                WHEN COALESCE(fl.es_contestada, FALSE) = FALSE OR COALESCE(fl.es_perdida, FALSE) = TRUE
                    THEN 1
                ELSE 0
            END
        )::BIGINT AS noContestadas,
        COALESCE(
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN COALESCE(fl.es_contestada, FALSE) = FALSE OR COALESCE(fl.es_perdida, FALSE) = TRUE
                                THEN 1
                            ELSE 0
                        END
                    ) * 100.0
                ) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaNoContestacion
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_cliente dc
        ON fl.sk_cliente = dc.sk_cliente
    JOIN dim_usuario du
        ON fl.sk_usuario_destino = du.sk_usuario
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
    GROUP BY du.nombre, du.apellido, du.numero_did
    ORDER BY tasaNoContestacion DESC, totalLlamadas DESC, nombreUsuario ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_23_colas_fuera_sla_detalle(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCola VARCHAR,
    esperaPromedio NUMERIC,
    esperaPercentil95 NUMERIC,
    maxEsperaPermitida NUMERIC,
    estadoSLA VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dcola.nombre::VARCHAR AS nombreCola,
        COALESCE(AVG(fl.tiempo_espera_seg), 0)::NUMERIC AS esperaPromedio,
        COALESCE(
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fl.tiempo_espera_seg),
            0
        )::NUMERIC AS esperaPercentil95,
        COALESCE(MAX(dcola.max_espera_segundos), 0)::NUMERIC AS maxEsperaPermitida,
        CASE
            WHEN COALESCE(AVG(fl.tiempo_espera_seg), 0) > COALESCE(MAX(dcola.max_espera_segundos), 0)
              OR COALESCE(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fl.tiempo_espera_seg), 0) > COALESCE(MAX(dcola.max_espera_segundos), 0)
                THEN 'FUERA_SLA'
            ELSE 'CUMPLE'
        END::VARCHAR AS estadoSLA
    FROM fact_llamada fl
    JOIN dim_tiempo d
        ON fl.sk_tiempo = d.sk_tiempo
    JOIN dim_cliente dc
        ON fl.sk_cliente = dc.sk_cliente
    JOIN dim_cola dcola
        ON fl.sk_cola = dcola.sk_cola
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND fl.tiempo_espera_seg IS NOT NULL
    GROUP BY dcola.nombre, dcola.max_espera_segundos
    ORDER BY esperaPromedio DESC, nombreCola ASC;
END;
$$;


CREATE OR REPLACE FUNCTION fn_reporte_24_grupos_criticos_mensajeria(
    p_id_entidad INT,
    p_anio INT,
    p_periodo INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreGrupo VARCHAR,
    volumenMensajes BIGINT,
    tasaRespuesta NUMERIC,
    tasaEntrega NUMERIC
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dg.nombre::VARCHAR AS nombreGrupo,
        COUNT(*)::BIGINT AS volumenMensajes,
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.es_respuesta THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaRespuesta,
        COALESCE(
            ROUND(
                (SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(*), 0),
                2
            ),
            0
        )::NUMERIC AS tasaEntrega
    FROM fact_mensaje fm
    JOIN dim_tiempo d
        ON fm.sk_tiempo = d.sk_tiempo
    JOIN dim_cliente dc
        ON fm.sk_cliente = dc.sk_cliente
    JOIN dim_grupo dg
        ON fm.sk_grupo = dg.sk_grupo
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (
            v_tipo_filtro = 'A'
         OR (v_tipo_filtro = 'M' AND d.mes = p_periodo)
         OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo)
      )
      AND COALESCE(fm.es_grupo, FALSE) = TRUE
      AND fm.sk_grupo IS NOT NULL
    GROUP BY dg.nombre
    ORDER BY volumenMensajes DESC, nombreGrupo ASC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_search_partners(
    p_query VARCHAR
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    estado VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        dp.id_partner::INT AS id,
        dp.nombre_partner::VARCHAR AS nombre,
        dp.estado_partner::VARCHAR AS estado
    FROM dim_partner dp
    WHERE dp.nombre_partner ILIKE '%' || TRIM(COALESCE(p_query, '')) || '%'
    ORDER BY
        CASE
            WHEN LOWER(dp.nombre_partner) = LOWER(TRIM(COALESCE(p_query, ''))) THEN 0
            WHEN LOWER(dp.nombre_partner) LIKE LOWER(TRIM(COALESCE(p_query, ''))) || '%' THEN 1
            ELSE 2
        END,
        dp.nombre_partner ASC
    LIMIT 20;
END;
$$;


CREATE OR REPLACE FUNCTION fn_search_clientes(
    p_query VARCHAR
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    estado VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        dc.id_cliente::INT AS id,
        dc.razon_social::VARCHAR AS nombre,
        dc.estado_cliente::VARCHAR AS estado
    FROM dim_cliente dc
    WHERE dc.razon_social ILIKE '%' || TRIM(COALESCE(p_query, '')) || '%'
    ORDER BY
        CASE
            WHEN LOWER(dc.razon_social) = LOWER(TRIM(COALESCE(p_query, ''))) THEN 0
            WHEN LOWER(dc.razon_social) LIKE LOWER(TRIM(COALESCE(p_query, ''))) || '%' THEN 1
            ELSE 2
        END,
        dc.razon_social ASC
    LIMIT 20;
END;
$$;
