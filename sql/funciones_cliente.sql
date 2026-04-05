-- ============================================================================
-- DASHBOARD CLIENTE - KPIs SUPERIORES
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_kpi_cliente_1_gasto_periodo(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (totalGasto NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc ON ff.sk_cliente       = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_2_monto_pagado(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (totalPagado NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.monto_pagado), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc ON ff.sk_cliente       = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_3_saldo_pendiente(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (saldoPendiente NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_cliente dc ON ff.sk_cliente       = dc.sk_cliente
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_4_uso_minutos(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (totalMinutos NUMERIC)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(fl.duracion_min), 0)::NUMERIC
    FROM fact_llamada fl
    JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
    JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_5_uso_mensajes(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (totalMensajes BIGINT)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT COUNT(*)::BIGINT
    FROM fact_mensaje fm
    JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
    JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo));
END; $$;


CREATE OR REPLACE FUNCTION fn_kpi_cliente_6_colas_fuera_sla(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (colasFueraSLA INT)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH cola_sla AS (
        SELECT
            fl.sk_cola,
            AVG(fl.tiempo_espera_seg)::NUMERIC                                     AS espera_prom,
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fl.tiempo_espera_seg)
                ::NUMERIC                                                           AS espera_p95,
            MAX(co.max_espera_segundos)::NUMERIC                                   AS max_espera
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        JOIN dim_cola    co ON fl.sk_cola    = co.sk_cola
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
          AND fl.sk_cola         IS NOT NULL
          AND fl.tiempo_espera_seg IS NOT NULL
        GROUP BY fl.sk_cola
    )
    SELECT COUNT(*)::INT
    FROM cola_sla
    WHERE espera_prom > max_espera
       OR espera_p95  > max_espera;
END; $$;


-- ============================================================================
-- REPORTES — CONTEXTO Y TENDENCIAS
-- ============================================================================
-- CTX 1 — Tendencia mensual de comunicaciones
CREATE OR REPLACE FUNCTION fn_reporte_cliente_1_tendencia_comunicaciones(
    p_id_entidad INT,
    p_anio       INT
)
RETURNS TABLE (
    anioReporte   INT,
    mesReporte    INT,
    totalLlamadas BIGINT,
    totalMensajes BIGINT,
    totalMinutos  NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH meses AS (
        SELECT
            EXTRACT(YEAR  FROM m)::INT AS yr,
            EXTRACT(MONTH FROM m)::INT AS mn
        FROM generate_series(
            MAKE_DATE(p_anio - 2, 1, 1),
            MAKE_DATE(p_anio,    12, 1),
            INTERVAL '1 month'
        ) m
    ),
    ll AS (
        SELECT
            dt.anio AS yr,
            dt.mes  AS mn,
            COUNT(*)::BIGINT                  AS n_ll,
            COALESCE(SUM(fl.duracion_min), 0) AS mins
        FROM fact_llamada fl
        JOIN dim_tiempo  dt ON fl.sk_tiempo  = dt.sk_tiempo
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND dt.anio BETWEEN (p_anio - 2) AND p_anio
        GROUP BY dt.anio, dt.mes
    ),
    msg AS (
        SELECT
            dt.anio AS yr,
            dt.mes  AS mn,
            COUNT(*)::BIGINT AS n_msg
        FROM fact_mensaje fm
        JOIN dim_tiempo  dt ON fm.sk_tiempo  = dt.sk_tiempo
        JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND dt.anio BETWEEN (p_anio - 2) AND p_anio
        GROUP BY dt.anio, dt.mes
    )
    SELECT
        m.yr::INT,
        m.mn::INT,
        COALESCE(ll.n_ll,   0)::BIGINT,
        COALESCE(msg.n_msg, 0)::BIGINT,
        COALESCE(ll.mins,   0)::NUMERIC
    FROM meses m
    LEFT JOIN ll  ON m.yr = ll.yr  AND m.mn = ll.mn
    LEFT JOIN msg ON m.yr = msg.yr AND m.mn = msg.mn
    ORDER BY m.yr, m.mn;
END; $$;


-- CTX 2 — Evolución del costo por interacción mensual  
CREATE OR REPLACE FUNCTION fn_reporte_cliente_2_costo_por_interaccion(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    mesReporte          INT,
    costoPorInteraccion NUMERIC,
    promedioMovil3m     NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH meses AS (
        SELECT
            EXTRACT(YEAR  FROM m)::INT AS yr,
            EXTRACT(MONTH FROM m)::INT AS mn
        FROM generate_series(
            MAKE_DATE(p_anio, 1, 1) - INTERVAL '5 months',
            MAKE_DATE(p_anio, 12, 1),
            INTERVAL '1 month'
        ) m
    ),
    ll AS (
        SELECT
            dt.anio AS yr,
            dt.mes  AS mn,
            COUNT(*)::BIGINT                        AS n_ll,
            COALESCE(SUM(fl.costo_llamada), 0)::NUMERIC AS costo_ll
        FROM fact_llamada fl
        JOIN dim_tiempo  dt ON fl.sk_tiempo  = dt.sk_tiempo
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
        GROUP BY dt.anio, dt.mes
    ),
    msg AS (
        SELECT
            dt.anio AS yr,
            dt.mes  AS mn,
            COUNT(*)::BIGINT                         AS n_msg,
            COALESCE(SUM(fm.costo_mensaje), 0)::NUMERIC AS costo_msg
        FROM fact_mensaje fm
        JOIN dim_tiempo  dt ON fm.sk_tiempo  = dt.sk_tiempo
        JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
        GROUP BY dt.anio, dt.mes
    ),
    combined AS (
        SELECT
            m.yr,
            m.mn,
            CASE
                WHEN COALESCE(ll.n_ll, 0) + COALESCE(msg.n_msg, 0) = 0 THEN 0::NUMERIC
                ELSE ROUND(
                    (COALESCE(ll.costo_ll, 0) + COALESCE(msg.costo_msg, 0))
                    / NULLIF(
                        (COALESCE(ll.n_ll, 0) + COALESCE(msg.n_msg, 0))::NUMERIC,
                        0
                    ), 4
                )
            END AS cpi
        FROM meses m
        LEFT JOIN ll  ON m.yr = ll.yr  AND m.mn = ll.mn
        LEFT JOIN msg ON m.yr = msg.yr AND m.mn = msg.mn
    ),
    con_promedio AS (
        SELECT
            yr,
            mn,
            cpi,
            ROUND(
                AVG(cpi) OVER (
                    ORDER BY yr, mn
                    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
                ), 4
            )::NUMERIC AS prom_3m
        FROM combined
    )
    SELECT
        mn::INT,
        cpi::NUMERIC,
        prom_3m::NUMERIC
    FROM con_promedio
    WHERE yr = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND mn = p_periodo)
        OR (v_tipo_filtro = 'T' AND CEIL(mn::NUMERIC / 3.0)::INT = p_periodo))
    ORDER BY mn;
END; $$;


-- CTX 3 — Uso de minutos y mensajes vs capacidad contratada
CREATE OR REPLACE FUNCTION fn_reporte_20_uso_vs_capacidad(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreFilial       VARCHAR,
    minutosConsumidos  NUMERIC,
    minutosCapacidad   NUMERIC,
    mensajesConsumidos BIGINT,
    mensajesCapacidad  BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH capacidad AS (
        SELECT
            ff.sk_cliente,
            COALESCE(SUM(dpp.minutos_incluidos  * ff.cantidad), 0)::NUMERIC AS min_cap,
            COALESCE(SUM(dpp.mensajes_incluidos * ff.cantidad), 0)::BIGINT  AS msg_cap
        FROM fact_facturacion ff
        JOIN dim_tiempo       d   ON ff.sk_fecha_emision = d.sk_tiempo
        JOIN dim_cliente      dc  ON ff.sk_cliente       = dc.sk_cliente
        JOIN dim_plan_producto dpp ON ff.sk_plan          = dpp.sk_plan
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
          AND dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY ff.sk_cliente
    ),
    consumo_ll AS (
        SELECT fl.sk_cliente,
               COALESCE(SUM(fl.duracion_min), 0)::NUMERIC AS min_consumidos
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY fl.sk_cliente
    ),
    consumo_msg AS (
        SELECT fm.sk_cliente,
               COUNT(*)::BIGINT AS msg_consumidos
        FROM fact_mensaje fm
        JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
        JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY fm.sk_cliente
    )
    SELECT
        dc.nombre_filial::VARCHAR,
        COALESCE(cl.min_consumidos, 0)::NUMERIC,
        COALESCE(cap.min_cap,        0)::NUMERIC,
        COALESCE(cm.msg_consumidos,  0)::BIGINT,
        COALESCE(cap.msg_cap,        0)::BIGINT
    FROM capacidad cap
    JOIN dim_cliente dc ON cap.sk_cliente = dc.sk_cliente
    LEFT JOIN consumo_ll  cl ON cap.sk_cliente = cl.sk_cliente
    LEFT JOIN consumo_msg cm ON cap.sk_cliente = cm.sk_cliente
    ORDER BY COALESCE(cl.min_consumidos, 0) DESC, dc.nombre_filial;
END; $$;


-- CTX 4 — Saturación horaria por filial y cola
CREATE OR REPLACE FUNCTION fn_reporte_21_saturacion_horaria(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreFilial    VARCHAR,
    nombreCola      VARCHAR,
    diaSemana       VARCHAR,
    horaDelDia      INT,
    volumenLlamadas BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dc.nombre_filial::VARCHAR,
        co.nombre::VARCHAR,
        d.dia_semana::VARCHAR,
        d.hora::INT,
        COUNT(*)::BIGINT
    FROM fact_llamada fl
    JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
    JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
    JOIN dim_cola    co ON fl.sk_cola    = co.sk_cola
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
    GROUP BY dc.nombre_filial, co.nombre, d.dia_semana, d.num_dia_semana, d.hora
    ORDER BY d.num_dia_semana, d.hora, COUNT(*) DESC;
END; $$;


-- CTX 5 — Embudo de contacto efectivo por filial
CREATE OR REPLACE FUNCTION fn_reporte_cliente_5_embudo_contacto_filial(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreFilial    VARCHAR,
    intentosTotales BIGINT,
    logrados        BIGINT,
    fallidos        BIGINT,
    pctEfectividad  NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH ll AS (
        SELECT
            dc.nombre_filial,
            COUNT(*)::BIGINT AS intentos_ll,
            SUM(CASE WHEN fl.es_contestada THEN 1 ELSE 0 END)::BIGINT AS logradas_ll,
            SUM(CASE WHEN fl.es_perdida OR fl.es_abandonada THEN 1 ELSE 0 END)::BIGINT AS fallidas_ll
        FROM fact_llamada fl
        JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
        JOIN dim_cliente dc ON fl.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.nombre_filial
    ),
    msg AS (
        SELECT
            dc.nombre_filial,
            COUNT(*)::BIGINT AS intentos_msg,
            SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END)::BIGINT AS logrados_msg,
            SUM(CASE WHEN NOT COALESCE(fm.fue_entregado, FALSE) THEN 1 ELSE 0 END)::BIGINT AS fallidos_msg
        FROM fact_mensaje fm
        JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
        JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
        WHERE dc.id_cliente = p_id_entidad
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY dc.nombre_filial
    ),
    filiales AS (
        SELECT nombre_filial FROM ll
        UNION
        SELECT nombre_filial FROM msg
    )
    SELECT
        f.nombre_filial::VARCHAR,
        (COALESCE(ll.intentos_ll,  0) + COALESCE(msg.intentos_msg, 0))::BIGINT AS intentos,
        (COALESCE(ll.logradas_ll,  0) + COALESCE(msg.logrados_msg,  0))::BIGINT AS logrados,
        (COALESCE(ll.fallidas_ll,  0) + COALESCE(msg.fallidos_msg,  0))::BIGINT AS fallidos,
        COALESCE(ROUND(
            (COALESCE(ll.logradas_ll, 0) + COALESCE(msg.logrados_msg, 0)) * 100.0
            / NULLIF(COALESCE(ll.intentos_ll, 0) + COALESCE(msg.intentos_msg, 0), 0), 2
        ), 0)::NUMERIC AS pct_efectividad
    FROM filiales f
    LEFT JOIN ll  ON f.nombre_filial = ll.nombre_filial
    LEFT JOIN msg ON f.nombre_filial = msg.nombre_filial
    ORDER BY pct_efectividad ASC, f.nombre_filial;
END; $$;


-- DET 6 — Estado de pagos, facturas y mora 
CREATE OR REPLACE FUNCTION fn_reporte_19_estado_pagos_facturas(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,     -- ignorado internamente; siempre vista anual
    p_tipo_filtro VARCHAR  -- ignorado internamente; siempre vista anual
)
RETURNS TABLE (
    idFactura      INT,
    fechaEmision   DATE,
    nombrePlan     VARCHAR,
    estadoFactura  VARCHAR,
    metodoPago     VARCHAR,
    montoTotal     NUMERIC,
    montoPagado    NUMERIC,
    saldoPendiente NUMERIC,
    diasMora       INT
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    SELECT
        ff.id_factura::INT,
        d.fecha::DATE,
        dpp.nombre_plan::VARCHAR,
        dep.estado_factura::VARCHAR,
        dep.metodo_pago::VARCHAR,
        COALESCE(ff.monto_total_factura, 0)::NUMERIC,
        COALESCE(ff.monto_pagado,        0)::NUMERIC,
        COALESCE(ff.saldo_pendiente,     0)::NUMERIC,
        COALESCE(ff.dias_mora,           0)::INT
    FROM fact_facturacion ff
    JOIN dim_tiempo        d   ON ff.sk_fecha_emision  = d.sk_tiempo
    JOIN dim_cliente       dc  ON ff.sk_cliente        = dc.sk_cliente
    LEFT JOIN dim_plan_producto dpp ON ff.sk_plan       = dpp.sk_plan
    LEFT JOIN dim_estado_pago   dep ON ff.sk_estado_pago = dep.sk_estado_pago
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA'
      AND dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
    ORDER BY d.fecha DESC, ff.id_factura DESC;
END; $$;


-- DET 7 — Usuarios con mayor tasa de no contestación
CREATE OR REPLACE FUNCTION fn_reporte_22_usuarios_no_contestacion(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreUsuario      VARCHAR,
    numeroDid          VARCHAR,
    totalLlamadas      BIGINT,
    noContestadas      BIGINT,
    tasaNoContestacion NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        (du.nombre || ' ' || du.apellido)::VARCHAR,
        du.numero_did::VARCHAR,
        COUNT(*)::BIGINT,
        SUM(CASE
            WHEN NOT COALESCE(fl.es_contestada, FALSE)
              OR COALESCE(fl.es_perdida, FALSE) THEN 1 ELSE 0
        END)::BIGINT,
        COALESCE(ROUND(
            SUM(CASE
                WHEN NOT COALESCE(fl.es_contestada, FALSE)
                  OR COALESCE(fl.es_perdida, FALSE) THEN 1 ELSE 0
            END) * 100.0 / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC
    FROM fact_llamada fl
    JOIN dim_tiempo  d  ON fl.sk_tiempo         = d.sk_tiempo
    JOIN dim_cliente dc ON fl.sk_cliente        = dc.sk_cliente
    JOIN dim_usuario du ON fl.sk_usuario_destino = du.sk_usuario
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
    GROUP BY du.nombre, du.apellido, du.numero_did
    HAVING COUNT(*) >= 3
    ORDER BY
        COALESCE(ROUND(
            SUM(CASE
                WHEN NOT COALESCE(fl.es_contestada, FALSE)
                  OR COALESCE(fl.es_perdida, FALSE) THEN 1 ELSE 0
            END) * 100.0 / NULLIF(COUNT(*), 0), 2), 0) DESC,
        COUNT(*) DESC,
        (du.nombre || ' ' || du.apellido);
END; $$;


-- DET 8 — Grupos con alta actividad y baja colaboración efectiva
CREATE OR REPLACE FUNCTION fn_reporte_cliente_9_grupos_colaboracion(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombreGrupo     VARCHAR,
    volumenMensajes BIGINT,
    tasaRespuesta   NUMERIC,
    tasaEntrega     NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dg.nombre::VARCHAR,
        COUNT(*)::BIGINT,
        COALESCE(ROUND(
            SUM(CASE WHEN fm.es_respuesta   THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC,
        COALESCE(ROUND(
            SUM(CASE WHEN fm.fue_entregado  THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC
    FROM fact_mensaje fm
    JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
    JOIN dim_cliente dc ON fm.sk_cliente = dc.sk_cliente
    JOIN dim_grupo   dg ON fm.sk_grupo   = dg.sk_grupo
    WHERE dc.id_cliente = p_id_entidad
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND COALESCE(fm.es_grupo, FALSE) = TRUE
      AND fm.sk_grupo IS NOT NULL
    GROUP BY dg.nombre
    ORDER BY COUNT(*) DESC, dg.nombre;
END; $$;


-- ============================================================================
-- UTILIDADES
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_search_clientes(p_query VARCHAR)
RETURNS TABLE (id INT, nombre VARCHAR, estado VARCHAR)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (dc.id_cliente)
        dc.id_cliente::INT,
        dc.razon_social::VARCHAR,
        dc.estado_cliente::VARCHAR
    FROM dim_cliente dc
    WHERE
        dc.razon_social ILIKE '%' || TRIM(COALESCE(p_query, '')) || '%'
        OR (TRIM(COALESCE(p_query,'')) ~ '^\d+$'
            AND dc.id_cliente = TRIM(p_query)::INT)
    ORDER BY
        dc.id_cliente,
        dc.razon_social
    LIMIT 20;
END; $$;
