-- =========================================================================
-- 1. TABLAS INDEPENDIENTES (Sin llaves foráneas)
-- =========================================================================

CREATE TABLE Integracion (
    ID_Integracion SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    tipo VARCHAR(20),
	proveedor VARCHAR(50),
    estado VARCHAR(20)
);

CREATE TABLE Rol (
    ID_Rol SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion VARCHAR(255),
    fecha_creacion TIMESTAMP,
    estado VARCHAR(20)
);

CREATE TABLE Partner (
    ID_Partner SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    dominio_portal VARCHAR(100),
    estado VARCHAR(20)
);

CREATE TABLE Cliente (
    ID_Cliente SERIAL PRIMARY KEY,
	razon_social VARCHAR(100),
    identificador_fiscal VARCHAR(50),
	dominio_tenant VARCHAR(25),
    timezone VARCHAR(50),
    fecha_alta DATE,
    estado VARCHAR(20)
);

CREATE TABLE Grupo (
    ID_Grupo SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion VARCHAR(255),
    tipo_grupo VARCHAR(32),
    fecha_creacion TIMESTAMP,
    estado VARCHAR(20)
);

CREATE TABLE Plan_Producto (
    ID_Plan SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion VARCHAR(255),
    costo_mensual NUMERIC(10, 2)
);

CREATE TABLE Cola_Llamadas (
    ID_Cola SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    estrategia VARCHAR(50),
    max_espera_segundos INT
);

-- =========================================================================
-- 2. TABLAS DE PRIMER NIVEL DE DEPENDENCIA
-- =========================================================================

CREATE TABLE Cliente_Integracion (
    ID_Cliente_Integracion SERIAL PRIMARY KEY,
    ID_Cliente INT,
    ID_Integracion INT,
    fecha_configuracion TIMESTAMP,
    referencia_externo VARCHAR(255),
    ultimo_sync_time TIMESTAMP,
    estado VARCHAR(20),
	FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente),
	FOREIGN KEY (ID_Integracion) REFERENCES Integracion(ID_Integracion)
);

CREATE TABLE Contrato (
    ID_Contrato SERIAL PRIMARY KEY,
    ID_Cliente INT,
    ID_Partner INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    fecha_renovacion DATE,
    duracion_meses INT,
    estado VARCHAR(20),
	FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente),
	FOREIGN KEY (ID_Partner) REFERENCES Partner(ID_Partner)
);

CREATE TABLE Factura (
    ID_Factura SERIAL PRIMARY KEY,
    ID_Cliente INT,
    periodo_inicio DATE,
    periodo_fin DATE,
    fecha_emision TIMESTAMP,
    monto_total NUMERIC(10, 2),
    estado VARCHAR(20),
	FOREIGN KEY (ID_Cliente) REFERENCES Contrato(ID_Cliente)
);

CREATE TABLE Filial (
    ID_Filial SERIAL PRIMARY KEY,
    ID_Cliente INT,
    nombre VARCHAR(100),
    direccion VARCHAR(255),
    ciudad VARCHAR(50),
    estado VARCHAR(20),
	FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)
);

CREATE TABLE Factura_Detalle (
	ID_Detalle SERIAL PRIMARY KEY,
	ID_Factura INT,
	concepto VARCHAR(100),
	cantidad INT,
	precio_unitario NUMERIC(10, 2),
	subtotal NUMERIC(10, 2),
	FOREIGN KEY (ID_Factura) REFERENCES Factura(ID_Factura)
);

-- =========================================================================
-- 3. TABLAS DE SEGUNDO NIVEL DE DEPENDENCIA
-- =========================================================================

CREATE TABLE Pago (
    ID_Pago SERIAL PRIMARY KEY,
    ID_Factura INT,
    fecha_pago TIMESTAMP,
    monto NUMERIC(10, 2),
    metodo_pago VARCHAR(50),
    estado VARCHAR(20),
	FOREIGN KEY (ID_Factura) REFERENCES Factura(ID_Factura)
);

CREATE TABLE Contrato_Item (
    ID_Item SERIAL PRIMARY KEY,
    ID_Contrato INT,
    ID_Plan INT,
    cantidad INT,
    precio_unitario NUMERIC(10, 2),
	FOREIGN KEY (ID_Contrato) REFERENCES Contrato(ID_Contrato),
	FOREIGN KEY (ID_Plan) REFERENCES Plan_Producto(ID_Plan)
);

CREATE TABLE Usuario (
    ID_Usuario SERIAL PRIMARY KEY,
    ID_Filial INT,
    nombre VARCHAR(50),
	apellido VARCHAR(50),
    email VARCHAR(255),
    password_hash VARCHAR(255),
    estado VARCHAR(20),
	FOREIGN KEY (ID_Filial) REFERENCES Filial(ID_Filial)
);

-- =========================================================================
-- 4. TABLAS DE TERCER NIVEL DE DEPENDENCIA (Dependen de Usuario)
-- =========================================================================

CREATE TABLE Bitacora (
    ID_Bitacora BIGSERIAL PRIMARY KEY,
    ID_Cliente INT,
	fecha TIMESTAMP,
	usuario VARCHAR(100),
    tabla VARCHAR(50),
    accion VARCHAR(20),
    id_registro_afectado INT,
    descripcion VARCHAR(255),
	FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)
);

CREATE TABLE Usuario_Rol (
    ID_Usuario INT,
    ID_Rol INT,
    fecha_asignacion TIMESTAMP,
    fecha_eliminacion TIMESTAMP,
    estado VARCHAR(20),
    PRIMARY KEY (ID_Usuario, ID_Rol),
	FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
    FOREIGN KEY (ID_Rol) REFERENCES Rol(ID_Rol)
);

CREATE TABLE Usuario_Grupo (
    ID_Usuario INT,
    ID_Grupo INT,
    rol_en_grupo VARCHAR(20),
    fecha_union TIMESTAMP,
    fecha_salida TIMESTAMP,
    PRIMARY KEY (ID_Usuario, ID_Grupo),
	FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
    FOREIGN KEY (ID_Grupo) REFERENCES Grupo(ID_Grupo)
);

CREATE TABLE Extension (
    ID_Extension SERIAL PRIMARY KEY,
    ID_Usuario INT,
    numero_extension VARCHAR(10),
    tipo VARCHAR(20),
    estado VARCHAR(20),
	FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario)
);

CREATE TABLE Mensaje_Grupo (
    ID_Mensaje_Grupo SERIAL PRIMARY KEY,
    ID_Usuario_Origen INT,
    ID_Grupo_Destino INT,
    contenido VARCHAR(2048),
    tipo_contenido VARCHAR(20),
    url VARCHAR(255),
    fecha_envio TIMESTAMP,
    plataforma_origen VARCHAR(50),
    ID_Mensaje_Original INT,
	FOREIGN KEY (ID_Usuario_Origen, ID_Grupo_Destino) REFERENCES Usuario_Grupo(ID_Usuario, ID_Grupo),
	FOREIGN KEY (ID_Mensaje_Original) REFERENCES Mensaje_Grupo(ID_Mensaje_Grupo)
);

CREATE TABLE Mensaje_Directo (
    ID_Mensaje_Directo SERIAL PRIMARY KEY,
    ID_Usuario_Origen INT,
    ID_Usuario_Destino INT,
    contenido VARCHAR(2048),
    tipo_contenido VARCHAR(20),
    url VARCHAR(255),
    fecha_envio TIMESTAMP,
    plataforma_origen VARCHAR(50),
    ID_Mensaje_Original INT,
	FOREIGN KEY (ID_Usuario_Origen) REFERENCES Usuario(ID_Usuario),
	FOREIGN KEY (ID_Usuario_Destino) REFERENCES Usuario(ID_Usuario),
	FOREIGN KEY (ID_Mensaje_Original) REFERENCES Mensaje_Directo(ID_Mensaje_Directo)
);

-- =========================================================================
-- 5. TABLAS DE CUARTO NIVEL DE DEPENDENCIA
-- =========================================================================

CREATE TABLE Estado_Entrega_Grupo (
    ID_Estado SERIAL PRIMARY KEY,
    ID_Mensaje_Grupo INT,
    ID_Usuario INT,
	ID_Grupo INT,
    estado VARCHAR(20),
	FOREIGN KEY (ID_Mensaje_Grupo) REFERENCES Mensaje_Grupo(ID_Mensaje_Grupo),
	FOREIGN KEY (ID_Usuario, ID_Grupo) REFERENCES Usuario_Grupo(ID_Usuario, ID_Grupo)
);

CREATE TABLE Estado_Entrega_Directo (
    ID_Estado SERIAL PRIMARY KEY,
    ID_Mensaje_Directo INT,
    fecha_evento TIMESTAMP,
    estado VARCHAR(20),
	FOREIGN KEY (ID_Mensaje_Directo) REFERENCES Mensaje_Directo(ID_Mensaje_Directo)
);

CREATE TABLE NumeroDID (
    ID_Numero SERIAL PRIMARY KEY,
    ID_Extension INT,
    numero VARCHAR(20),
    tipo VARCHAR(20),
    estado VARCHAR(20),
	FOREIGN KEY (ID_Extension) REFERENCES Extension(ID_Extension)
);

-- =========================================================================
-- 6. TABLAS DE QUINTO NIVEL DE DEPENDENCIA (Dependen de NumeroDID)
-- =========================================================================

-- Tabla con llave primaria que a la vez es foránea (Relación 1 a 1)
CREATE TABLE Buzon_Voz (
    ID_Numero INT PRIMARY KEY,
    pin VARCHAR(10),
    reenvio_email VARCHAR(255),
    ruta_saludo VARCHAR(255),
    FOREIGN KEY (ID_Numero) REFERENCES NumeroDID(ID_Numero)
);

CREATE TABLE Endpoint (
    ID_Endpoint SERIAL PRIMARY KEY,
    ID_Numero INT,
    tipo VARCHAR(50),
    fecha_creacion TIMESTAMP,
    fecha_eliminacion TIMESTAMP,
    estado VARCHAR(20),
	FOREIGN KEY (ID_Numero) REFERENCES NumeroDID(ID_Numero)
);

CREATE TABLE Llamada (
    ID_Llamada SERIAL PRIMARY KEY,
    ID_Numero_Origen INT,
    ID_Numero_Destino INT,
    ID_Cola INT,
    tipo_llamada VARCHAR(20),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    duracion_seg BIGINT,
    estado VARCHAR(20),
    plataforma_origen VARCHAR(50),
	FOREIGN KEY (ID_Numero_Origen) REFERENCES NumeroDID(ID_Numero),
	FOREIGN KEY (ID_Numero_Destino) REFERENCES NumeroDID(ID_Numero),
	FOREIGN KEY (ID_Cola) REFERENCES Cola_Llamadas(ID_Cola)
);

-- =========================================================================
-- 7. TABLAS DE SEXTO NIVEL DE DEPENDENCIA
-- =========================================================================

CREATE TABLE Mensaje_Buzon (
    ID_MensajeVoz SERIAL PRIMARY KEY,
    ID_Numero INT,
    numero_origen VARCHAR(20),
    ruta_archivo VARCHAR(255),
    duracion_seg BIGINT,
    fecha TIMESTAMP,
    estado VARCHAR(20),
	FOREIGN KEY (ID_Numero) REFERENCES Buzon_Voz(ID_Numero)
);
