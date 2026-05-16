# Enreach — Data Warehouse & Business Intelligence

> Implementación y consumo de un Data Warehouse para el sistema de telecomunicaciones Enreach (PBX/UCaaS).

---

## Descripción

Este proyecto diseña, construye y consume un **Data Warehouse** a partir del modelo operacional de Enreach. La información se procesa mediante transformaciones ETL, se carga en un modelo dimensional y se expone en una aplicación web con tres dashboards analíticos: **Vista Enreach**, **Vista Partner** y **Vista Cliente**.

La solución permite consultar indicadores de facturación, cobranza, uso de servicios, calidad operativa, mensajería, llamadas, vencimientos contractuales y comportamiento de clientes dentro del ecosistema Enreach.

---

## Flujo del Proyecto

```text
OLTP PostgreSQL
   ↓
ETL Pentaho Spoon
   ↓
Data Warehouse PostgreSQL
   ↓
Funciones SQL analíticas
   ↓
API REST Spring Boot
   ↓
Frontend React + Vite
```

---

## Stack Tecnológico

| Capa / Módulo | Tecnología |
|---------------|------------|
| Base operacional | PostgreSQL |
| ETL | Pentaho Spoon |
| Data Warehouse | PostgreSQL 16 · Modelo dimensional Kimball |
| Backend | Java 17 · Spring Boot 3.2.4 · Spring Data JPA |
| Frontend | React 18 · Vite 7 · React Router · Recharts |

---

## Estructura del Repositorio

```text
proyecto_bd2_enreach/
├── app/
│   ├── dashboard-dw/      # API REST Spring Boot
│   └── enreach-app/       # Frontend React + Vite
├── screenshots/           # Capturas de la aplicación en ejecución
├── etl/                   # Transformaciones Pentaho Spoon
├── graphs/                # Diagramas del modelo relacional y dimensional
├── sql/                   # Scripts SQL, bloques de carga y funciones analíticas
└── README.md
```

---

## Modelo Dimensional

**Tablas de hechos:**

- `fact_facturacion`
- `fact_llamada`
- `fact_mensaje`

**Dimensiones principales:**

- `dim_tiempo`
- `dim_cliente`
- `dim_partner`
- `dim_plan_producto`
- `dim_contrato`
- `dim_acuerdo`
- `dim_cola`
- `dim_usuario`
- `dim_grupo`
- `dim_estado_pago`

---

## Cobertura Analítica

| Vista | Enfoque | KPIs | Reportes |
|-------|---------|------|----------|
| Enreach | Vista ejecutiva global del negocio | 6 | 9 |
| Partner | Gestión comercial y operativa del canal | 6 | 8 |
| Cliente | Control operativo del tenant/cliente | 6 | 8 |

---

## Rutas de la Aplicación

| Ruta | Descripción |
|------|-------------|
| `/` | Landing page de acceso al sistema |
| `/enreach` | Dashboard ejecutivo Enreach |
| `/partner/:id` | Dashboard analítico por partner |
| `/cliente/:id` | Dashboard analítico por cliente |

---

## API REST

La API del backend se expone bajo la ruta base:

```text
/api/dashboard
```

Controladores principales:

| Módulo | Ruta base |
|--------|-----------|
| Enreach | `/api/dashboard/enreach` |
| Partner | `/api/dashboard/partner` |
| Cliente | `/api/dashboard/cliente` |

---

## Capturas de Pantalla

Las capturas se encuentran en la carpeta:

```text
screenshots/
```

### Landing Page

| Portada principal | Selección de nivel de análisis |
|-------------------|--------------------------------|
| <img src="screenshots/landing_page1.png" alt="Landing page principal de Enreach Data Warehouse" width="100%"> | <img src="screenshots/landing_page2.png" alt="Landing page con selección de vista Enreach, Partner y Cliente" width="100%"> |

### Vista Enreach

Dashboard ejecutivo para monitorear el comportamiento global del negocio, incluyendo facturación, cobranza, revenue, demanda, llamadas, mensajería y vencimientos de acuerdos.

| Dashboard ejecutivo | Facturación y cobranza |
|---------------------|------------------------|
| <img src="screenshots/enreach/1.png" alt="Vista Enreach con KPIs ejecutivos y gráfico de facturación" width="100%"> | <img src="screenshots/enreach/2.png" alt="Vista Enreach con reporte de facturado vs cobrado" width="100%"> |

| Tendencia y riesgo financiero | Revenue por país |
|-------------------------------|------------------|
| <img src="screenshots/enreach/3.png" alt="Vista Enreach con tendencia de facturación anual y riesgo financiero" width="100%"> | <img src="screenshots/enreach/4.png" alt="Vista Enreach con riesgo financiero y revenue por país" width="100%"> |

| Demanda horaria y canalización | Salud de mensajería |
|--------------------------------|---------------------|
| <img src="screenshots/enreach/5.png" alt="Vista Enreach con demanda horaria y canalización de llamadas" width="100%"> | <img src="screenshots/enreach/6.png" alt="Vista Enreach con salud de mensajería" width="100%"> |

| Detalle granular |
|------------------|
| <img src="screenshots/enreach/7.png" alt="Vista Enreach con detalle granular, scorecard y vencimientos de acuerdos" width="100%"> |

### Vista Partner

Dashboard orientado al análisis de cada partner, con indicadores de facturación, cobranza, cartera, uso contratado, crecimiento de clientes, llamadas, mensajería y vencimientos de contratos.

| Dashboard del partner | Selector de partner |
|-----------------------|---------------------|
| <img src="screenshots/partner/1.png" alt="Vista Partner con KPIs y reporte de facturación por cliente" width="100%"> | <img src="screenshots/partner/2.png" alt="Vista Partner con selector desplegable de partners" width="100%"> |

| Facturación por cliente | Aging de cartera y uso del plan |
|-------------------------|---------------------------------|
| <img src="screenshots/partner/3.png" alt="Vista Partner con facturado vs cobrado por cliente" width="100%"> | <img src="screenshots/partner/4.png" alt="Vista Partner con aging de cartera y uso real vs plan" width="100%"> |

| Crecimiento, llamadas y mensajería | Calidad de mensajería |
|------------------------------------|-----------------------|
| <img src="screenshots/partner/5.png" alt="Vista Partner con crecimiento de clientes, deterioro de llamadas y calidad de mensajería" width="100%"> | <img src="screenshots/partner/6.png" alt="Vista Partner con gráfico de calidad de mensajería" width="100%"> |

| Mesa operativa | Vencimientos de contratos |
|----------------|---------------------------|
| <img src="screenshots/partner/7.png" alt="Vista Partner con mesa operativa de clientes" width="100%"> | <img src="screenshots/partner/8.png" alt="Vista Partner con tabla de vencimientos de contratos" width="100%"> |

### Vista Cliente

Dashboard para analizar un cliente específico, con métricas de comunicación, costos, capacidad, saturación horaria, embudo de contacto, estado de pagos, colaboración y usuarios con mayor no contestación.

| Dashboard del cliente | Selector de cliente |
|-----------------------|---------------------|
| <img src="screenshots/cliente/1.png" alt="Vista Cliente con KPIs y tendencia de comunicaciones" width="100%"> | <img src="screenshots/cliente/2.png" alt="Vista Cliente con selector desplegable de clientes" width="100%"> |

| Tendencias y costos | Capacidad y saturación |
|---------------------|------------------------|
| <img src="screenshots/cliente/3.png" alt="Vista Cliente con tendencia de comunicaciones y costo por interacción" width="100%"> | <img src="screenshots/cliente/4.png" alt="Vista Cliente con uso vs capacidad y saturación horaria" width="100%"> |

| Embudo de contacto | Estado de pagos y colaboración |
|--------------------|--------------------------------|
| <img src="screenshots/cliente/5.png" alt="Vista Cliente con saturación horaria y embudo de contacto por filial" width="100%"> | <img src="screenshots/cliente/6.png" alt="Vista Cliente con estado de pagos, grupos de colaboración y usuarios no contestación" width="100%"> |

| Usuarios con mayor no contestación |
|------------------------------------|
| <img src="screenshots/cliente/7.png" alt="Vista Cliente con usuarios con mayor no contestación" width="100%"> |

---

## Ejecución

### Backend

Desde la raíz del repositorio:

```bash
cd app/dashboard-dw
mvn spring-boot:run
```

El backend queda disponible en:

```text
http://localhost:8080
```

### Frontend

Desde la raíz del repositorio:

```bash
cd app/enreach-app
npm install
npm run dev
```

El frontend queda disponible en:

```text
http://localhost:5173
```

### Variable de entorno del frontend

Crear un archivo `.env` en `app/enreach-app/` con la URL base de la API:

```env
VITE_API_BASE_URL=http://localhost:8080/api/dashboard
```

> Si no se define esta variable, el frontend usa por defecto `http://localhost:8080/api/dashboard`.

---

## Integrantes

| Integrante | Rol / Módulo |
|------------|--------------|
| Karel González | Vista Enreach |
| Justin Soledispa | Vista Partner |
| Juan Diego Sotomayor | Vista Cliente |

---

*Proyecto académico — Base de Datos 2 · Universidad Espíritu Santo (UEES) · 2026*
