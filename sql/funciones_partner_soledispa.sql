
-- DASHBOARD PARTNER - KPIs SUPERIORES

CREATE OR REPLACE FUNCTION fn_kpi_partner_1_facturacion_periodo(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (totalFacturado NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_2_cobro_periodo(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (totalCobrado NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_3_cartera_vencida(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (carteraVencida NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND COALESCE(ff.saldo_pendiente, 0) > 0
      AND COALESCE(ff.dias_mora, 0)       > 0;
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_4_clientes_activos(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (clientesActivos INT)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT dc.id_cliente)::INT
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    JOIN dim_cliente dc ON ff.sk_cliente       = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_5_uso_promedio_plan(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (usoPromedioPorcentaje NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH capacidad AS (
        SELECT COALESCE(SUM(dpp.minutos_incluidos * ff.cantidad), 0)::NUMERIC AS min_incluidos
        FROM fact_facturacion ff
        JOIN dim_tiempo       d   ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner      dp  ON ff.sk_partner       = dp.sk_partner
        JOIN dim_plan_producto dpp ON ff.sk_plan          = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
    ),
    consumo AS (
        SELECT COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS min_consumidos
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
    )
    SELECT COALESCE(
        ROUND(consumo.min_consumidos * 100.0 / NULLIF(capacidad.min_incluidos, 0), 2), 0
    )::NUMERIC
    FROM capacidad CROSS JOIN consumo;
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_partner_6_tasa_entrega_mensajes(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (tasaEntrega NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(ROUND(
        SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC
    FROM fact_mensaje fm
    JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
    JOIN dim_partner dp ON fm.sk_partner = dp.sk_partner
    WHERE dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_9_facturado_cobrado_cliente(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente  VARCHAR,
    totalFacturado NUMERIC,
    totalCobrado   NUMERIC,
    saldoPendiente NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC,
        COALESCE(SUM(ff.monto_pagado),        0)::NUMERIC,
        COALESCE(SUM(ff.saldo_pendiente),     0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    JOIN dim_cliente dc ON ff.sk_cliente       = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
    GROUP BY dc.razon_social
    ORDER BY SUM(ff.monto_total_factura) DESC, dc.razon_social;
END; $$;



CREATE OR REPLACE FUNCTION fn_reporte_10_aging_cartera_cliente(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente  VARCHAR,
    rangoDias      VARCHAR,
    ordenBucket    INT,
    saldoPendiente NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR,
        CASE
            WHEN ff.dias_mora BETWEEN 0  AND 30 THEN '0-30 dias'
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN '31-60 dias'
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN '61-90 dias'
            ELSE '> 90 dias'
        END::VARCHAR                                    AS rangoDias,
        CASE
            WHEN ff.dias_mora BETWEEN 0  AND 30 THEN 1
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN 2
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN 3
            ELSE 4
        END::INT                                        AS ordenBucket,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC  AS saldoPendiente
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    JOIN dim_cliente dc ON ff.sk_cliente       = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND COALESCE(ff.saldo_pendiente, 0) > 0
    GROUP BY
        dc.razon_social,
        CASE
            WHEN ff.dias_mora BETWEEN 0  AND 30 THEN '0-30 dias'
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN '31-60 dias'
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN '61-90 dias'
            ELSE '> 90 dias'
        END,
        CASE
            WHEN ff.dias_mora BETWEEN 0  AND 30 THEN 1
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN 2
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN 3
            ELSE 4
        END
    ORDER BY dc.razon_social,
        CASE
            WHEN ff.dias_mora BETWEEN 0  AND 30 THEN 1
            WHEN ff.dias_mora BETWEEN 31 AND 60 THEN 2
            WHEN ff.dias_mora BETWEEN 61 AND 90 THEN 3
            ELSE 4
        END;
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_11_uso_real_vs_plan(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente      VARCHAR,
    nombrePlan         VARCHAR,
    minutosConsumidos  NUMERIC,
    minutosIncluidos   NUMERIC,
    mensajesConsumidos BIGINT,
    mensajesIncluidos  BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH capacidad AS (
        SELECT
            dc.id_cliente,
            ff.sk_plan,
            COALESCE(SUM(dpp.minutos_incluidos  * ff.cantidad), 0)::NUMERIC AS min_incluidos,
            COALESCE(SUM(dpp.mensajes_incluidos * ff.cantidad), 0)::BIGINT  AS msg_incluidos
        FROM fact_facturacion ff
        JOIN dim_tiempo       d   ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner      dp  ON ff.sk_partner       = dp.sk_partner
        JOIN dim_cliente      dc  ON ff.sk_cliente       = dc.sk_cliente
        JOIN dim_plan_producto dpp ON ff.sk_plan          = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente, ff.sk_plan
    ),
    consumo_ll AS (
        SELECT
            dc.id_cliente,
            fl.sk_plan,
            COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS min_consumidos
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente, fl.sk_plan
    ),
    consumo_msg AS (
        SELECT
            dc.id_cliente,
            fm.sk_plan,
            COUNT(*)::BIGINT AS msg_consumidos
        FROM fact_mensaje fm
        JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fm.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente, fm.sk_plan
    )
    SELECT
        MIN(dc.razon_social)::VARCHAR            AS nombreCliente,
        MIN(dpp.nombre_plan)::VARCHAR            AS nombrePlan,
        COALESCE(MAX(cl.min_consumidos), 0)::NUMERIC AS minutosConsumidos,
        COALESCE(cap.min_incluidos, 0)::NUMERIC  AS minutosIncluidos,
        COALESCE(MAX(cm.msg_consumidos), 0)::BIGINT  AS mensajesConsumidos,
        COALESCE(cap.msg_incluidos, 0)::BIGINT   AS mensajesIncluidos
    FROM capacidad cap
    JOIN dim_cliente      dc  ON cap.id_cliente = dc.id_cliente
    JOIN dim_plan_producto dpp ON cap.sk_plan    = dpp.sk_plan
    LEFT JOIN consumo_ll cl ON cap.id_cliente = cl.id_cliente AND cap.sk_plan = cl.sk_plan
    LEFT JOIN consumo_msg cm ON cap.id_cliente = cm.id_cliente AND cap.sk_plan = cm.sk_plan
    GROUP BY cap.id_cliente, cap.sk_plan, cap.min_incluidos, cap.msg_incluidos
    ORDER BY COALESCE(MAX(cl.min_consumidos), 0) DESC, MIN(dc.razon_social);
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_14_deterioro_llamadas(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR,
    p_limite      INT DEFAULT 4,
    p_offset      INT DEFAULT 0
)
RETURNS TABLE (
    nombreCliente  VARCHAR,
    totalLlamadas  BIGINT,
    perdidas       BIGINT,
    abandonadas    BIGINT,
    tasaPerdida    NUMERIC,
    tasaAbandono   NUMERIC,
    totalRegistros BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro  VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
    v_prev_anio    INT;
    v_prev_periodo INT;
BEGIN
    v_prev_anio    := CASE WHEN v_tipo_filtro = 'M' AND p_periodo = 1 THEN p_anio - 1
                           WHEN v_tipo_filtro = 'T' AND p_periodo = 1 THEN p_anio - 1
                           ELSE p_anio END;
    v_prev_periodo := CASE WHEN v_tipo_filtro = 'M' AND p_periodo = 1 THEN 12
                           WHEN v_tipo_filtro = 'M'                    THEN p_periodo - 1
                           WHEN v_tipo_filtro = 'T' AND p_periodo = 1 THEN 4
                           WHEN v_tipo_filtro = 'T'                    THEN p_periodo - 1
                           ELSE NULL END;

    RETURN QUERY
    WITH actual AS (
        SELECT
            dc.id_cliente,
            COUNT(*)::BIGINT                                               AS total_ll,
            SUM(CASE WHEN fl.es_perdida    THEN 1 ELSE 0 END)::BIGINT     AS perdidas,
            SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END)::BIGINT     AS abandonadas,
            ROUND(SUM(CASE WHEN fl.es_perdida    THEN 1 ELSE 0 END) * 100.0
                  / NULLIF(COUNT(*), 0), 2)::NUMERIC                       AS tasa_p,
            ROUND(SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END) * 100.0
                  / NULLIF(COUNT(*), 0), 2)::NUMERIC                       AS tasa_a
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente
    ),
    previo AS (
        SELECT
            dc.id_cliente,
            ROUND(SUM(CASE WHEN fl.es_perdida    THEN 1 ELSE 0 END) * 100.0
                  / NULLIF(COUNT(*), 0), 2)::NUMERIC AS tasa_p,
            ROUND(SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END) * 100.0
                  / NULLIF(COUNT(*), 0), 2)::NUMERIC AS tasa_a
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = v_prev_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = v_prev_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = v_prev_periodo))
        GROUP BY dc.id_cliente
    ),
    resultado AS (
        SELECT
            MIN(dc.razon_social)::VARCHAR                                  AS nombre,
            COALESCE(a.total_ll,   0)::BIGINT                             AS total_ll,
            COALESCE(a.perdidas,   0)::BIGINT                             AS perdidas,
            COALESCE(a.abandonadas,0)::BIGINT                             AS abandonadas,
            COALESCE(a.tasa_p - p.tasa_p, a.tasa_p, 0)::NUMERIC          AS delta_p,
            COALESCE(a.tasa_a - p.tasa_a, a.tasa_a, 0)::NUMERIC          AS delta_a
        FROM actual a
        JOIN dim_cliente dc ON a.id_cliente = dc.id_cliente
        LEFT JOIN previo p  ON a.id_cliente = p.id_cliente
        GROUP BY a.id_cliente, a.total_ll, a.perdidas, a.abandonadas,
                 a.tasa_p, p.tasa_p, a.tasa_a, p.tasa_a
    )
    SELECT
        r.nombre,
        r.total_ll,
        r.perdidas,
        r.abandonadas,
        r.delta_p,
        r.delta_a,
        COUNT(*) OVER ()::BIGINT AS totalRegistros
    FROM resultado r
    ORDER BY r.delta_p DESC, r.delta_a DESC, r.nombre
    LIMIT  p_limite
    OFFSET p_offset;
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_15_calidad_mensajeria_cliente(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente    VARCHAR,
    totalMensajes    BIGINT,
    tasaEntrega      NUMERIC,
    tasaRespuesta    NUMERIC,
    mensajesGrupo    BIGINT,
    mensajesDirectos BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.razon_social::VARCHAR,
        COUNT(*)::BIGINT,
        COALESCE(ROUND(SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC,
        COALESCE(ROUND(SUM(CASE WHEN fm.es_respuesta  THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC,
        SUM(CASE WHEN fm.es_grupo                        THEN 1 ELSE 0 END)::BIGINT,
        SUM(CASE WHEN NOT COALESCE(fm.es_grupo, FALSE)   THEN 1 ELSE 0 END)::BIGINT
    FROM fact_mensaje fm
    JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
    JOIN dim_partner dp ON fm.sk_partner = dp.sk_partner
    JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
    WHERE dp.id_partner = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
    GROUP BY dc.razon_social
    ORDER BY COUNT(*) DESC, dc.razon_social;
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_partner_8_crecimiento_neto_clientes(
    p_id_entidad INT,
    p_anio       INT
)
RETURNS TABLE (
    anioReporte      INT,
    trimestreReporte INT,
    altas            BIGINT,
    bajas            BIGINT,
    neto             BIGINT
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH altas AS (
        SELECT
            dt_ini.anio      AS yr,
            dt_ini.trimestre AS tri,
            COUNT(DISTINCT dc.id_cliente)::BIGINT AS cnt_altas
        FROM fact_facturacion ff
        JOIN dim_partner dp     ON ff.sk_partner              = dp.sk_partner
        JOIN dim_cliente dc     ON ff.sk_cliente              = dc.sk_cliente
        JOIN dim_tiempo  dt_ini ON ff.sk_fecha_inicio_contrato = dt_ini.sk_tiempo
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND dt_ini.anio BETWEEN (p_anio - 1) AND p_anio
        GROUP BY dt_ini.anio, dt_ini.trimestre
    ),
    bajas AS (
        SELECT
            dt_fin.anio      AS yr,
            dt_fin.trimestre AS tri,
            COUNT(DISTINCT dc.id_cliente)::BIGINT AS cnt_bajas
        FROM fact_facturacion ff
        JOIN dim_partner  dp    ON ff.sk_partner             = dp.sk_partner
        JOIN dim_cliente  dc    ON ff.sk_cliente             = dc.sk_cliente
        JOIN dim_contrato dcon  ON ff.sk_contrato            = dcon.sk_contrato
        JOIN dim_tiempo   dt_fin ON ff.sk_fecha_fin_contrato = dt_fin.sk_tiempo
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND UPPER(TRIM(COALESCE(dcon.estado, ''))) IN ('FINALIZADO', 'SUSPENDIDO')
          AND dt_fin.anio BETWEEN (p_anio - 1) AND p_anio
        GROUP BY dt_fin.anio, dt_fin.trimestre
    ),
    periodos AS (
        SELECT yr, tri FROM altas
        UNION
        SELECT yr, tri FROM bajas
    )
    SELECT
        per.yr::INT,
        per.tri::INT,
        COALESCE(a.cnt_altas, 0)::BIGINT,
        COALESCE(b.cnt_bajas, 0)::BIGINT,
        (COALESCE(a.cnt_altas, 0) - COALESCE(b.cnt_bajas, 0))::BIGINT
    FROM periodos per
    LEFT JOIN altas a ON per.yr = a.yr AND per.tri = a.tri
    LEFT JOIN bajas b ON per.yr = b.yr AND per.tri = b.tri
    ORDER BY per.yr, per.tri;
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_16_mesa_operativa_clientes(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreCliente        VARCHAR,
    saldoPendiente       NUMERIC,
    diasMora             INT,
    usoPlanPorcentaje    NUMERIC,
    tasaPerdidaLlamadas  NUMERIC,
    tasaEntregaMensajes  NUMERIC,
    colaCritica          VARCHAR
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH ff_agg AS (
        SELECT
            dc.id_cliente,
            COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC AS saldo,
            COALESCE(MAX(ff.dias_mora),        0)::INT    AS mora,
            COALESCE(SUM(dpp.minutos_incluidos * ff.cantidad), 0)::NUMERIC AS min_incluidos
        FROM fact_facturacion ff
        JOIN dim_tiempo       d   ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_partner      dp  ON ff.sk_partner       = dp.sk_partner
        JOIN dim_cliente      dc  ON ff.sk_cliente       = dc.sk_cliente
        JOIN dim_plan_producto dpp ON ff.sk_plan          = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente
    ),
    fl_agg AS (
        SELECT
            dc.id_cliente,
            COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS min_consumidos,
            COALESCE(ROUND(
                SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) * 100.0
                / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC  AS tasa_perdida
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente
    ),
    fm_agg AS (
        SELECT
            dc.id_cliente,
            COALESCE(ROUND(
                SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0
                / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC AS tasa_entrega
        FROM fact_mensaje fm
        JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fm.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente
    ),
    cola_critica AS (
        SELECT DISTINCT ON (dc.id_cliente)
            dc.id_cliente,
            co.nombre::VARCHAR AS cola
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        JOIN dim_cola    co ON fl.sk_cola    = co.sk_cola
        WHERE dp.id_partner = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.id_cliente, co.nombre
        ORDER BY dc.id_cliente,
                 AVG(fl.tiempo_espera_seg) DESC,
                 SUM(CASE WHEN fl.es_perdida THEN 1 ELSE 0 END) DESC
    )
    SELECT
        MIN(dc.razon_social)::VARCHAR                                    AS nombreCliente,
        COALESCE(ff.saldo, 0)::NUMERIC,
        COALESCE(ff.mora,  0)::INT,
        COALESCE(ROUND(
            COALESCE(fl.min_consumidos, 0) * 100.0
            / NULLIF(ff.min_incluidos, 0), 2), 0)::NUMERIC              AS usoPlanPorcentaje,
        COALESCE(fl.tasa_perdida,  0)::NUMERIC,
        COALESCE(fm.tasa_entrega,  0)::NUMERIC,
        COALESCE(cc.cola, 'SIN COLA')::VARCHAR
    FROM ff_agg ff
    JOIN dim_cliente dc ON ff.id_cliente = dc.id_cliente
    LEFT JOIN fl_agg fl ON ff.id_cliente = fl.id_cliente
    LEFT JOIN fm_agg fm ON ff.id_cliente = fm.id_cliente
    LEFT JOIN cola_critica cc ON ff.id_cliente = cc.id_cliente
    GROUP BY ff.id_cliente, ff.saldo, ff.mora, ff.min_incluidos,
             fl.min_consumidos, fl.tasa_perdida,
             fm.tasa_entrega, cc.cola
    ORDER BY ff.saldo DESC, fl.tasa_perdida DESC, MIN(dc.razon_social);
END; $$;


CREATE OR REPLACE FUNCTION fn_reporte_partner_12_vencimientos_contratos(
    p_id_entidad INT
)
RETURNS TABLE (
    nombreCliente  VARCHAR,
    nombrePlan     VARCHAR,
    estadoContrato VARCHAR,
    fechaFin       DATE,
    diasRestantes  INT,
    urgencia       VARCHAR
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH base AS (
        SELECT
            dc.id_cliente,
            MIN(dc.razon_social)                        AS cliente,
            MIN(dpp.nombre_plan)                        AS plan,
            UPPER(TRIM(dcon.estado))                    AS estado_contrato,
            MAX(dt_fin.fecha)                           AS fecha_fin,
            dcon.sk_contrato
        FROM fact_facturacion ff
        JOIN dim_partner      dp    ON ff.sk_partner             = dp.sk_partner
        JOIN dim_cliente      dc    ON ff.sk_cliente             = dc.sk_cliente
        JOIN dim_contrato     dcon  ON ff.sk_contrato            = dcon.sk_contrato
        JOIN dim_plan_producto dpp  ON ff.sk_plan                = dpp.sk_plan
        JOIN dim_tiempo       dt_fin ON ff.sk_fecha_fin_contrato = dt_fin.sk_tiempo
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dp.id_partner = p_id_entidad
        GROUP BY dc.id_cliente, dcon.sk_contrato, dcon.estado
    )
    SELECT
        cliente::VARCHAR,
        plan::VARCHAR,
        estado_contrato::VARCHAR,
        fecha_fin::DATE,
        (fecha_fin - CURRENT_DATE)::INT                AS diasRestantes,
        CASE
            WHEN (fecha_fin - CURRENT_DATE) < 0  THEN 'VENCIDO'
            WHEN (fecha_fin - CURRENT_DATE) < 30 THEN 'CRITICO'
            WHEN (fecha_fin - CURRENT_DATE) < 90 THEN 'ALERTA'
            ELSE                                      'VIGENTE'
        END::VARCHAR                                   AS urgencia
    FROM base
    ORDER BY (fecha_fin - CURRENT_DATE) ASC, cliente;
END; $$;