-- ========================================
-- Tabla: CATEGORIA
-- ========================================
CREATE TABLE categoria (
    id_categoria NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

-- ========================================
-- Tabla: ARTICULO
-- ========================================
CREATE TABLE articulo (
    codigo_barras VARCHAR2(50) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    precio_venta NUMBER(10,2) NOT NULL,
    precio_compra NUMBER(10,2) NOT NULL,
    stock NUMBER DEFAULT 0,
    fotografia BLOB,
    id_categoria NUMBER NOT NULL,
    CONSTRAINT fk_articulo_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria(id_categoria)
);

-- ========================================
-- Tabla: PROVEEDOR
-- ========================================
CREATE TABLE proveedor (
    rfc VARCHAR2(13) PRIMARY KEY,
    razon_social VARCHAR2(100) NOT NULL,
    direccion VARCHAR2(200),
    telefono VARCHAR2(20),
    cuenta_pago VARCHAR2(50)
);

-- ========================================
-- Tabla: ARTICULO_PROVEEDOR (histórico)
-- ========================================
CREATE TABLE articulo_proveedor (
    codigo_barras VARCHAR2(50),
    rfc_proveedor VARCHAR2(13),
    fecha_inicio DATE DEFAULT SYSDATE,
    PRIMARY KEY (codigo_barras, rfc_proveedor),
    CONSTRAINT fk_ap_articulo FOREIGN KEY (codigo_barras) REFERENCES articulo(codigo_barras),
    CONSTRAINT fk_ap_proveedor FOREIGN KEY (rfc_proveedor) REFERENCES proveedor(rfc)
);

-- ========================================
-- Tabla: CLIENTE
-- ========================================
CREATE TABLE cliente (
    rfc VARCHAR2(13) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    razon_social VARCHAR2(100),
    direccion VARCHAR2(200),
    email VARCHAR2(100),
    telefono VARCHAR2(20)
);

-- ========================================
-- Tabla: SUCURSAL
-- ========================================
CREATE TABLE sucursal (
    id_sucursal NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    ubicacion VARCHAR2(200) NOT NULL,
    telefono VARCHAR2(20),
    anio_fundacion NUMBER(4)
);

-- ========================================
-- Tabla: EMPLEADO
-- ========================================
CREATE TABLE empleado (
    num_empleado NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    rfc VARCHAR2(13) NOT NULL,
    curp VARCHAR2(18) NOT NULL,
    direccion VARCHAR2(200),
    telefono VARCHAR2(20),
    email VARCHAR2(100),
    fecha_ingreso DATE NOT NULL,
    tipo_empleado VARCHAR2(20) NOT NULL,
    rol VARCHAR2(50),
    supervisor_num_empleado NUMBER,
    id_sucursal NUMBER NOT NULL,
    CONSTRAINT fk_empleado_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
    CONSTRAINT fk_empleado_supervisor FOREIGN KEY (supervisor_num_empleado) REFERENCES empleado(num_empleado),
    CONSTRAINT chk_tipo_empleado CHECK (tipo_empleado IN ('cajero', 'vendedor', 'administrativo', 'seguridad', 'limpieza'))
);

-- ========================================
-- Tabla: VENTA
-- ========================================
CREATE TABLE venta (
    folio VARCHAR2(20) PRIMARY KEY,
    fecha DATE NOT NULL,
    monto_total NUMBER(10,2),
    cantidad_total_articulos NUMBER,
    vendedor_num_empleado NUMBER NOT NULL,
    cajero_num_empleado NUMBER NOT NULL,
    rfc_cliente VARCHAR2(13),
    CONSTRAINT fk_venta_vendedor FOREIGN KEY (vendedor_num_empleado) REFERENCES empleado(num_empleado),
    CONSTRAINT fk_venta_cajero FOREIGN KEY (cajero_num_empleado) REFERENCES empleado(num_empleado),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (rfc_cliente) REFERENCES cliente(rfc)
);

-- ========================================
-- Tabla: DETALLE_VENTA
-- ========================================
CREATE TABLE detalle_venta (
    folio_venta VARCHAR2(20),
    codigo_barras VARCHAR2(50),
    cantidad NUMBER NOT NULL,
    monto_parcial NUMBER(10,2),
    PRIMARY KEY (folio_venta, codigo_barras),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (folio_venta) REFERENCES venta(folio),
    CONSTRAINT fk_detalle_articulo FOREIGN KEY (codigo_barras) REFERENCES articulo(codigo_barras)
);

-- ========================================
-- VISTA: TICKET_VENTA (solo ilustrativa)
-- ========================================
CREATE VIEW vista_ticket_venta AS
SELECT 
    v.folio,
    v.fecha,
    c.nombre AS cliente,
    e1.nombre AS vendedor,
    e2.nombre AS cajero,
    a.nombre AS articulo,
    dv.cantidad,
    dv.monto_parcial
FROM venta v
JOIN cliente c ON v.rfc_cliente = c.rfc
JOIN empleado e1 ON v.vendedor_num_empleado = e1.num_empleado
JOIN empleado e2 ON v.cajero_num_empleado = e2.num_empleado
JOIN detalle_venta dv ON v.folio = dv.folio_venta
JOIN articulo a ON dv.codigo_barras = a.codigo_barras;

-- ========================================
-- VISTA: ARTICULOS_NO_DISPONIBLES
-- ========================================
CREATE VIEW articulos_no_disponibles AS
SELECT 
    codigo_barras,
    nombre,
    stock,
    CASE 
        WHEN stock = 0 THEN 'No disponible'
        ELSE 'Stock bajo'
    END AS estado
FROM articulo
WHERE stock <= 3;

-- ========================================
-- ÍNDICE EJEMPLO (por nombre de artículo)
-- ========================================
CREATE INDEX idx_articulo_nombre ON articulo(nombre);

