-- ============================================================================
-- DASHBOARD ENREACH - KAREL GONZALEZ 
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

-- Reporte CTX 1 — Facturado vs cobrado
CREATE OR REPLACE FUNCTION fn_reporte_1_facturado_vs_cobrado(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner   VARCHAR,
    totalFacturado  NUMERIC,
    totalCobrado    NUMERIC,
    saldoPendiente  NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC,
        COALESCE(SUM(ff.monto_pagado),        0)::NUMERIC,
        COALESCE(SUM(ff.saldo_pendiente),     0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.nombre_partner
    ORDER BY SUM(ff.monto_total_factura) DESC, dp.nombre_partner;
END; $$;


-- Reporte CTX 2 — Riesgo financiero
CREATE OR REPLACE FUNCTION fn_reporte_2_riesgo_financiero(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner    VARCHAR,
    saldoPendiente   NUMERIC,
    diasMoraPromedio NUMERIC,
    contratosActivos INT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR,
        COALESCE(SUM(ff.saldo_pendiente), 0)::NUMERIC,
        COALESCE(AVG(ff.dias_mora),       0)::NUMERIC,
        COUNT(DISTINCT CASE WHEN ff.sk_acuerdo <> 0 THEN ff.sk_acuerdo END)::INT
    FROM fact_facturacion ff
    JOIN dim_tiempo  d  ON ff.sk_fecha_emision = d.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
      AND COALESCE(ff.saldo_pendiente, 0) > 0
    GROUP BY dp.nombre_partner
    ORDER BY SUM(ff.saldo_pendiente) DESC, dp.nombre_partner;
END; $$;

-- Reporte CTX 3 — Demanda horaria global de voz
CREATE OR REPLACE FUNCTION fn_reporte_3_demanda_horaria_voz(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
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
        d.dia_semana::VARCHAR,
        d.hora::INT,
        COUNT(*)::BIGINT
    FROM fact_llamada fl
    JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
    JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY d.dia_semana, d.num_dia_semana, d.hora
    ORDER BY d.num_dia_semana, d.hora;
END; $$;

-- Reporte CTX 4 — Contestación de llamadas por partner (donut)
CREATE OR REPLACE FUNCTION fn_reporte_4_calidad_llamadas_partner(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner    VARCHAR,
    totalLlamadas    BIGINT,
    contestadas      BIGINT,
    perdidas         BIGINT,
    abandonadas      BIGINT,
    tasaContestacion NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR,
        COUNT(*)::BIGINT,
        SUM(CASE WHEN fl.es_contestada  THEN 1 ELSE 0 END)::BIGINT,
        SUM(CASE WHEN fl.es_perdida     THEN 1 ELSE 0 END)::BIGINT,
        SUM(CASE WHEN fl.es_abandonada  THEN 1 ELSE 0 END)::BIGINT,
        COALESCE(ROUND(
            SUM(CASE WHEN fl.es_contestada THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(*), 0), 2
        ), 0)::NUMERIC
    FROM fact_llamada fl
    JOIN dim_tiempo  d  ON fl.sk_tiempo  = d.sk_tiempo
    JOIN dim_partner dp ON fl.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.nombre_partner
    ORDER BY COUNT(*) DESC, dp.nombre_partner;
END; $$;

-- Reporte CTX 5 — Salud de mensajería por partner
CREATE OR REPLACE FUNCTION fn_reporte_5_salud_mensajeria_partner(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner   VARCHAR,
    totalMensajes   BIGINT,
    entregados      BIGINT,
    tasaEntrega     NUMERIC,
    mensajesGrupo   BIGINT,
    mensajesDirecto BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    SELECT
        dp.nombre_partner::VARCHAR,
        COUNT(*)::BIGINT,
        SUM(CASE WHEN fm.fue_entregado              THEN 1 ELSE 0 END)::BIGINT,
        COALESCE(ROUND(
            SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0
            / NULLIF(COUNT(*), 0), 2
        ), 0)::NUMERIC,
        SUM(CASE WHEN fm.es_grupo                  THEN 1 ELSE 0 END)::BIGINT,
        SUM(CASE WHEN NOT COALESCE(fm.es_grupo, FALSE) THEN 1 ELSE 0 END)::BIGINT
    FROM fact_mensaje fm
    JOIN dim_tiempo  d  ON fm.sk_tiempo  = d.sk_tiempo
    JOIN dim_partner dp ON fm.sk_partner = dp.sk_partner
    WHERE d.anio = p_anio
      AND (v_tipo_filtro = 'A'
        OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
        OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.nombre_partner
    ORDER BY COUNT(*) DESC, dp.nombre_partner;
END; $$;

-- Reporte CTX 6 — Tendencia de facturacion anual por partner
CREATE OR REPLACE FUNCTION fn_reporte_enreach_6_tendencia_facturacion_anual(
    p_id_entidad INT,
    p_anio       INT
)
RETURNS TABLE (
    nombrePartner  VARCHAR,
    anioReporte    INT,
    totalFacturado NUMERIC,
    variacionPct   NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH base AS (
        SELECT
            dp.nombre_partner           AS partner_r,
            dt.anio                     AS yr,
            COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS facturado_r
        FROM fact_facturacion ff
        JOIN dim_tiempo  dt ON ff.sk_fecha_emision = dt.sk_tiempo
        JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
          AND dt.anio BETWEEN (p_anio - 2) AND p_anio
          AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
        GROUP BY dp.nombre_partner, dt.anio
    ),
    con_lag AS (
        SELECT
            partner_r,
            yr,
            facturado_r,
            LAG(facturado_r) OVER (PARTITION BY partner_r ORDER BY yr) AS facturado_ant
        FROM base
    )
    SELECT
        partner_r::VARCHAR,
        yr::INT,
        facturado_r::NUMERIC,
        CASE
            WHEN facturado_ant IS NULL OR facturado_ant = 0 THEN NULL
            ELSE ROUND(
                (facturado_r - facturado_ant) * 100.0 / facturado_ant, 2
            )::NUMERIC
        END
    FROM con_lag
    ORDER BY partner_r, yr;
END; $$;

-- Reporte CTX 7 — Revenue e indicadores por país de partner 
CREATE OR REPLACE FUNCTION fn_reporte_enreach_7_revenue_por_pais(
    p_id_entidad INT,
    p_anio       INT
)
RETURNS TABLE (
    paisPartner     VARCHAR,
    totalClientes   INT,
    totalFacturado  NUMERIC,
    saldoPendiente  NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    SELECT
        dp.pais_partner::VARCHAR,
        COUNT(DISTINCT ff.sk_cliente)::INT,
        COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC,
        COALESCE(SUM(ff.saldo_pendiente),     0)::NUMERIC
    FROM fact_facturacion ff
    JOIN dim_tiempo  dt ON ff.sk_fecha_emision = dt.sk_tiempo
    JOIN dim_partner dp ON ff.sk_partner       = dp.sk_partner
    WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
      AND dt.anio = p_anio
      AND (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
    GROUP BY dp.pais_partner
    ORDER BY SUM(ff.monto_total_factura) DESC;
END; $$;


-- Reporte DET 8 — Scorecard operativo de partners críticos
CREATE OR REPLACE FUNCTION fn_reporte_8_scorecard_partners(
    p_id_entidad  INT,
    p_anio        INT,
    p_periodo     INT,
    p_tipo_filtro VARCHAR
)
RETURNS TABLE (
    nombrePartner        VARCHAR,
    revenue              NUMERIC,
    saldoPendiente       NUMERIC,
    diasMora             INT,
    tasaPerdida          NUMERIC,
    tasaAbandono         NUMERIC,
    tasaEntregaMensajes  NUMERIC
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_tipo_filtro VARCHAR(1) := UPPER(TRIM(COALESCE(p_tipo_filtro, 'M')));
BEGIN
    RETURN QUERY
    WITH ff_agg AS (
        SELECT
            ff.sk_partner,
            COALESCE(SUM(ff.monto_total_factura), 0)::NUMERIC AS revenue,
            COALESCE(SUM(ff.saldo_pendiente),     0)::NUMERIC AS saldo,
            COALESCE(MAX(ff.dias_mora),           0)::INT     AS mora
        FROM fact_facturacion ff
        JOIN dim_tiempo d ON d.sk_tiempo = ff.sk_fecha_emision
        WHERE UPPER(TRIM(COALESCE(ff.tipo_facturacion, ''))) = 'FACTURA_PARTNER'
          AND d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY ff.sk_partner
    ),
    fl_agg AS (
        SELECT
            fl.sk_partner,
            COALESCE(ROUND(
                SUM(CASE WHEN fl.es_perdida    THEN 1 ELSE 0 END) * 100.0
                / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC AS tasa_perdida,
            COALESCE(ROUND(
                SUM(CASE WHEN fl.es_abandonada THEN 1 ELSE 0 END) * 100.0
                / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC AS tasa_abandono
        FROM fact_llamada fl
        JOIN dim_tiempo d ON d.sk_tiempo = fl.sk_tiempo
        WHERE d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY fl.sk_partner
    ),
    fm_agg AS (
        SELECT
            fm.sk_partner,
            COALESCE(ROUND(
                SUM(CASE WHEN fm.fue_entregado THEN 1 ELSE 0 END) * 100.0
                / NULLIF(COUNT(*), 0), 2), 0)::NUMERIC AS tasa_entrega
        FROM fact_mensaje fm
        JOIN dim_tiempo d ON d.sk_tiempo = fm.sk_tiempo
        WHERE d.anio = p_anio
          AND (v_tipo_filtro = 'A'
            OR (v_tipo_filtro = 'M' AND d.mes       = p_periodo)
            OR (v_tipo_filtro = 'T' AND d.trimestre = p_periodo))
        GROUP BY fm.sk_partner
    )
    SELECT
        dp.nombre_partner::VARCHAR,
        COALESCE(ff_agg.revenue,       0)::NUMERIC,
        COALESCE(ff_agg.saldo,         0)::NUMERIC,
        COALESCE(ff_agg.mora,          0)::INT,
        COALESCE(fl_agg.tasa_perdida,  0)::NUMERIC,
        COALESCE(fl_agg.tasa_abandono, 0)::NUMERIC,
        COALESCE(fm_agg.tasa_entrega,  0)::NUMERIC
    FROM dim_partner dp
    LEFT JOIN ff_agg ON ff_agg.sk_partner = dp.sk_partner
    LEFT JOIN fl_agg ON fl_agg.sk_partner = dp.sk_partner
    LEFT JOIN fm_agg ON fm_agg.sk_partner = dp.sk_partner
    WHERE (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
      AND (ff_agg.sk_partner IS NOT NULL
        OR fl_agg.sk_partner IS NOT NULL
        OR fm_agg.sk_partner IS NOT NULL)
    ORDER BY COALESCE(ff_agg.revenue, 0) DESC, dp.nombre_partner;
END; $$;

-- Reporte DET 9 — Vencimientos de acuerdos por partner  
CREATE OR REPLACE FUNCTION fn_reporte_enreach_9_vencimientos_acuerdos(
    p_id_entidad INT
)
RETURNS TABLE (
    nombrePartner  VARCHAR,
    nivelAcuerdo   INT,
    estadoAcuerdo  VARCHAR,
    fechaFin       DATE,
    diasRestantes  INT,
    revenueTotal   NUMERIC,
    urgencia       VARCHAR
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH base AS (
        SELECT
            dp.nombre_partner,
            da.nivel_acuerdo,
            da.estado_acuerdo,
            da.sk_acuerdo,
            MAX(dt_fin.fecha)                           AS fecha_fin,
            COALESCE(SUM(ff.monto_total_factura), 0)    AS revenue
        FROM fact_facturacion ff
        JOIN dim_partner dp  ON ff.sk_partner           = dp.sk_partner
        JOIN dim_acuerdo da  ON ff.sk_acuerdo            = da.sk_acuerdo
        JOIN dim_tiempo dt_fin
                             ON ff.sk_fecha_fin_acuerdo = dt_fin.sk_tiempo
        WHERE (p_id_entidad IS NULL OR dp.id_partner = p_id_entidad)
        GROUP BY
            dp.nombre_partner,
            da.nivel_acuerdo,
            da.estado_acuerdo,
            da.sk_acuerdo
    )
    SELECT
        nombre_partner::VARCHAR,
        nivel_acuerdo::INT,
        estado_acuerdo::VARCHAR,
        fecha_fin::DATE,
        (fecha_fin - CURRENT_DATE)::INT        AS diasRestantes,
        revenue::NUMERIC,
        CASE
            WHEN (fecha_fin - CURRENT_DATE) < 0  THEN 'VENCIDO'
            WHEN (fecha_fin - CURRENT_DATE) < 30 THEN 'CRITICO'
            WHEN (fecha_fin - CURRENT_DATE) < 90 THEN 'ALERTA'
            ELSE                                      'VIGENTE'
        END::VARCHAR                           AS urgencia
    FROM base
    ORDER BY (fecha_fin - CURRENT_DATE) ASC, revenue DESC;
END; $$;
