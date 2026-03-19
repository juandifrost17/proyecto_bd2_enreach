# Enreach — Data Warehouse & Business Intelligence
> Proyecto de implementación y consumo de un Data Warehouse para el sistema de telecomunicaciones Enreach.

## Descripción del Proyecto
Este proyecto consiste en el diseño, construcción y consumo de un **Data Warehouse (DW)** a partir del modelo OLTP del sistema de telecomunicaciones **Enreach**, una plataforma PBX/UCaaS que gestiona llamadas, extensiones, numeración DID, colas de llamadas, facturación, mensajería y buzones de voz.

El objetivo es transformar los datos operacionales en un modelo dimensional optimizado para el análisis histórico y la toma de decisiones estratégicas del negocio.

### Flujo general del proyecto

```
Base de datos OLTP (PostgreSQL)
        │
        ▼
   Proceso ETL (Pentaho Spoon)
        │
        ▼
   Data Warehouse (PostgreSQL - Modelo Estrella)
        │
        ▼
   Aplicación consumidora 
        └── Dashboards, reportes y consultas interactivas
```

## Arquitectura

| Capa                | Tecnología         | Descripción                                       |
|---------------------|--------------------|---------------------------------------------------|
| Base OLTP           | PostgreSQL         | Modelo relacional normalizado (29 tablas)         |
| ETL                 | Pentaho Spoon      | Extracción, transformación y carga de datos       |
| Data Warehouse      | PostgreSQL         | Modelo dimensional estrella                       |
| Aplicación          | Java + JavaScript  | Interfaz de dashboards, reportes y filtrado       |
| Control de versiones| Git + GitHub       | Versionamiento y colaboración del equipo          |

## Integrantes del grupo
- Karel González
- Justin Soledispa
- Juan Diego Sotomayor
