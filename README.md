# Enreach — Data Warehouse & Business Intelligence

> Implementación y consumo de un Data Warehouse para el sistema de telecomunicaciones Enreach (PBX/UCaaS).

## Descripción

Diseño, construcción y consumo de un **Data Warehouse** a partir del modelo OLTP de Enreach. Los datos operacionales se transforman en un modelo dimensional que alimenta tres dashboards analíticos: **Vista Enreach** (ejecutiva global), **Vista Partner** (gestión del canal) y **Vista Cliente** (control operativo del tenant).

## Flujo del Proyecto

```
OLTP (PostgreSQL) → ETL (Pentaho Spoon) → DW (PostgreSQL) → API REST (Spring Boot) → Frontend (React)
```

## Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| ETL | Pentaho Spoon |
| Data Warehouse | 3 Data Marts (Kimball) |
| Lógica analítica | PostgreSQL (45 funciones) |
| API REST | Java 17 · Spring Boot 3.2.4 |
| Frontend | React 18 · Vite 7 · Recharts |

## Modelo Dimensional

**Hechos:** `fact_facturacion`, `fact_llamada`, `fact_mensaje`

**Dimensiones:** `dim_tiempo`, `dim_cliente`, `dim_partner`, `dim_plan_producto`, `dim_contrato`, `dim_acuerdo`, `dim_cola`, `dim_usuario`, `dim_grupo`, `dim_estado_pago`

## Cobertura Analítica

| Vista | KPIs | Reportes |
|-------|------|----------|
| Enreach | 6 | 9 |
| Partner | 6 | 8 |
| Cliente | 6 | 8 |

## Ejecución

### Backend
```bash
# Configurar application.properties y levantar
# Abrir la terminal en la carpeta: dashboard-dw
mvn spring-boot:run
# → http://localhost:8080
```

### Frontend
```bash
# Abrir la terminal en la carpeta: enreach-app
npm install
npm run dev
# → http://localhost:5173
```

**Variable de entorno requerida:** `VITE_API_BASE_URL=http://localhost:8080`

## Integrantes

| Integrante | Módulo |
|------------|--------|
| Karel González | Vista Enreach |
| Justin Soledispa | Vista Partner |
| Juan Diego Sotomayor | Vista Cliente |
