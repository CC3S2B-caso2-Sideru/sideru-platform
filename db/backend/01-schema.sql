-- ============================================
-- Backend DB — Schema (monolito residual)
-- Tablas: Ventas + Logística + RRHH
--
-- NOTA: Las FKs a tablas en otras DBs se eliminaron
-- (cliente, usuario, producto están en iam_db y catalogo_db).
-- Las columnas de referencia se mantienen como INT para trazabilidad.
--
-- Las columnas producto_sku y producto_nombre en los detalles
-- son snapshots inmutables: capturan los datos del producto
-- al momento de la cotización/pedido. Esto evita dependencia
-- del Catálogo en consultas y garantiza integridad histórica
-- de los documentos comerciales.
-- ============================================

-- ==============================
--  VENTAS
-- ==============================

CREATE TYPE estado_cotizacion AS ENUM (
    'borrador', 'enviada', 'aceptada', 'rechazada', 'expirada'
);

CREATE TABLE cotizacion
(
    id               SERIAL PRIMARY KEY,
    cliente_id       INT               NOT NULL,  -- FK lógica a iam_db.cliente
    fecha_emision    TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    fecha_expiracion DATE              NOT NULL,
    estado           estado_cotizacion NOT NULL DEFAULT 'borrador',
    observaciones    TEXT,
    subtotal         DECIMAL(12, 2)    NOT NULL DEFAULT 0,
    descuento_total  DECIMAL(12, 2)    NOT NULL DEFAULT 0,
    igv              DECIMAL(12, 2)    NOT NULL DEFAULT 0,
    total            DECIMAL(12, 2)    NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

CREATE TABLE cotizacion_detalle
(
    id              SERIAL PRIMARY KEY,
    cotizacion_id   INT            NOT NULL,
    producto_id     INT            NOT NULL,  -- FK lógica a catalogo_db.producto
    /*
     * Snapshot inmutable del producto al momento de la cotización.
     * Garantiza que el documento conserve los datos originales aunque
     * el producto cambie en el Catálogo.
     */
    producto_sku    VARCHAR(50)    NOT NULL,
    producto_nombre VARCHAR(150)   NOT NULL,
    cantidad        INT            NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento       DECIMAL(5, 2)  NOT NULL DEFAULT 0,
    subtotal        DECIMAL(12, 2) NOT NULL,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (cotizacion_id) REFERENCES cotizacion (id)
);

CREATE TYPE estado_pedido AS ENUM (
    'pendiente', 'confirmado', 'en_preparacion',
    'despachado', 'entregado', 'cancelado', 'rechazado_stock'
);

CREATE TABLE pedido
(
    id             SERIAL PRIMARY KEY,
    cotizacion_id  INT            NOT NULL UNIQUE,
    cliente_id     INT            NOT NULL,  -- FK lógica a iam_db.cliente
    fecha_pedido   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    estado         estado_pedido  NOT NULL DEFAULT 'pendiente',
    motivo_rechazo TEXT,
    total          DECIMAL(12, 2) NOT NULL,
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (cotizacion_id) REFERENCES cotizacion (id)
);

CREATE TABLE pedido_detalle
(
    id              SERIAL PRIMARY KEY,
    pedido_id       INT            NOT NULL,
    producto_id     INT            NOT NULL,  -- FK lógica a catalogo_db.producto
    /*
     * Snapshot inmutable del producto al momento del pedido.
     */
    producto_sku    VARCHAR(50)    NOT NULL,
    producto_nombre VARCHAR(150)   NOT NULL,
    cantidad        INT            NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento       DECIMAL(5, 2)  NOT NULL DEFAULT 0,
    subtotal        DECIMAL(12, 2) NOT NULL,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (pedido_id) REFERENCES pedido (id)
);

CREATE TYPE tipo_comprobante AS ENUM ('factura', 'boleta');
CREATE TYPE estado_pago AS ENUM ('pendiente', 'pagado', 'anulado');

CREATE TABLE comprobante
(
    id            SERIAL PRIMARY KEY,
    pedido_id     INT              NOT NULL,
    tipo          tipo_comprobante NOT NULL,
    serie         VARCHAR(4)       NOT NULL,
    numero        VARCHAR(8)       NOT NULL,
    fecha_emision TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    subtotal      DECIMAL(12, 2)   NOT NULL,
    igv           DECIMAL(12, 2)   NOT NULL,
    total         DECIMAL(12, 2)   NOT NULL,
    estado_pago   estado_pago      NOT NULL DEFAULT 'pendiente',
    fecha_pago    TIMESTAMPTZ,
    metodo_pago   VARCHAR(50),
    created_at    TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    UNIQUE (serie, numero),
    FOREIGN KEY (pedido_id) REFERENCES pedido (id)
);

-- Índices Ventas
CREATE INDEX idx_cotizacion_cliente ON cotizacion (cliente_id);
CREATE INDEX idx_cotizacion_estado ON cotizacion (estado);
CREATE INDEX idx_pedido_estado ON pedido (estado);
CREATE INDEX idx_pedido_cliente ON pedido (cliente_id);
CREATE INDEX idx_comprobante_pedido ON comprobante (pedido_id);
CREATE INDEX idx_pedido_created_at ON pedido (created_at);
CREATE INDEX idx_comprobante_created_at ON comprobante (created_at);

-- ==============================
--  LOGÍSTICA
-- ==============================

CREATE TABLE proveedor
(
    id           SERIAL PRIMARY KEY,
    ruc          VARCHAR(11) UNIQUE NOT NULL,
    razon_social VARCHAR(200)       NOT NULL,
    contacto     VARCHAR(100),
    email        VARCHAR(150),
    telefono     VARCHAR(20),
    direccion    TEXT,
    activo       BOOLEAN                     DEFAULT TRUE,
    created_at   TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ        NOT NULL DEFAULT NOW()
);

CREATE TYPE estado_orden_compra AS ENUM (
    'borrador', 'enviada', 'confirmada', 'recibida_parcial', 'recibida', 'anulada'
);

CREATE TABLE orden_compra
(
    id                SERIAL PRIMARY KEY,
    proveedor_id      INT                 NOT NULL,
    fecha_emision     TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    fecha_estimada    DATE,
    estado            estado_orden_compra NOT NULL DEFAULT 'borrador',
    requiere_prestamo BOOLEAN                      DEFAULT FALSE,
    total_estimado    DECIMAL(12, 2)      NOT NULL DEFAULT 0,
    observaciones     TEXT,
    created_at        TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    FOREIGN KEY (proveedor_id) REFERENCES proveedor (id)
);

CREATE TABLE orden_compra_detalle
(
    id              SERIAL PRIMARY KEY,
    orden_compra_id INT            NOT NULL,
    producto_id     INT            NOT NULL,  -- FK lógica a catalogo_db
    cantidad        INT            NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal        DECIMAL(12, 2) NOT NULL,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (orden_compra_id) REFERENCES orden_compra (id)
);

CREATE TABLE recepcion_mercaderia
(
    id              SERIAL PRIMARY KEY,
    orden_compra_id INT         NOT NULL,
    fecha_recepcion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    observaciones   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (orden_compra_id) REFERENCES orden_compra (id)
);

CREATE TABLE recepcion_detalle
(
    id                      SERIAL PRIMARY KEY,
    recepcion_mercaderia_id INT         NOT NULL,
    producto_id             INT         NOT NULL,  -- FK lógica a catalogo_db
    cantidad_recibida       INT         NOT NULL CHECK (cantidad_recibida > 0),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (recepcion_mercaderia_id) REFERENCES recepcion_mercaderia (id)
);

CREATE TABLE factura_proveedor
(
    id              SERIAL PRIMARY KEY,
    orden_compra_id INT            NOT NULL,
    numero_factura  VARCHAR(50)    NOT NULL,
    fecha_factura   DATE           NOT NULL,
    monto_total     DECIMAL(12, 2) NOT NULL,
    estado_pago     estado_pago    NOT NULL DEFAULT 'pendiente',
    fecha_pago      DATE,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (orden_compra_id) REFERENCES orden_compra (id)
);

-- Índices Logística
CREATE INDEX idx_orden_compra_proveedor ON orden_compra (proveedor_id);
CREATE INDEX idx_orden_compra_estado ON orden_compra (estado);
CREATE INDEX idx_orden_compra_created_at ON orden_compra (created_at);

-- ==============================
--  RECURSOS HUMANOS
-- ==============================

CREATE TABLE cargo
(
    id           SERIAL PRIMARY KEY,
    nombre       VARCHAR(100)   NOT NULL UNIQUE,
    descripcion  TEXT,
    salario_base DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TABLE departamento
(
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE empleado
(
    id              SERIAL PRIMARY KEY,
    usuario_id      INT UNIQUE,          -- FK lógica a iam_db.usuario
    departamento_id INT                 NOT NULL,
    cargo_id        INT                 NOT NULL,
    dni             VARCHAR(8) UNIQUE   NOT NULL,
    nombres         VARCHAR(100)        NOT NULL,
    apellidos       VARCHAR(100)        NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    telefono        VARCHAR(20),
    fecha_ingreso   DATE                NOT NULL,
    fecha_cese      DATE,
    salario         DECIMAL(10, 2)      NOT NULL,
    cuenta_bancaria VARCHAR(30),
    activo          BOOLEAN                      DEFAULT TRUE,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    FOREIGN KEY (departamento_id) REFERENCES departamento (id),
    FOREIGN KEY (cargo_id) REFERENCES cargo (id)
);

CREATE TYPE tipo_marcado AS ENUM ('entrada', 'salida');

CREATE TABLE asistencia
(
    id          SERIAL PRIMARY KEY,
    empleado_id INT          NOT NULL,
    fecha       DATE         NOT NULL,
    tipo        tipo_marcado NOT NULL,
    hora        TIME         NOT NULL,
    ip_origen   VARCHAR(45),
    observacion TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    FOREIGN KEY (empleado_id) REFERENCES empleado (id)
);

CREATE TYPE estado_justificacion AS ENUM ('pendiente', 'aprobada', 'rechazada');

CREATE TABLE justificacion
(
    id               SERIAL PRIMARY KEY,
    empleado_id      INT                  NOT NULL,
    fecha_incidencia DATE                 NOT NULL,
    tipo_incidencia  VARCHAR(50)          NOT NULL,
    descripcion      TEXT                 NOT NULL,
    estado           estado_justificacion NOT NULL DEFAULT 'pendiente',
    revisado_por     INT,
    fecha_revision   TIMESTAMPTZ,
    created_at       TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
    FOREIGN KEY (empleado_id) REFERENCES empleado (id),
    FOREIGN KEY (revisado_por) REFERENCES empleado (id)
);

CREATE TABLE planilla
(
    id            SERIAL PRIMARY KEY,
    periodo       VARCHAR(7)  NOT NULL,
    fecha_proceso TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    procesado_por INT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (periodo),
    FOREIGN KEY (procesado_por) REFERENCES empleado (id)
);

CREATE TABLE planilla_detalle
(
    id                  SERIAL PRIMARY KEY,
    planilla_id         INT            NOT NULL,
    empleado_id         INT            NOT NULL,
    dias_trabajados     INT            NOT NULL DEFAULT 0,
    dias_falta          INT            NOT NULL DEFAULT 0,
    dias_tardanza       INT            NOT NULL DEFAULT 0,
    horas_extras        DECIMAL(5, 2)  NOT NULL DEFAULT 0,
    salario_bruto       DECIMAL(10, 2) NOT NULL,
    descuento_faltas    DECIMAL(10, 2) NOT NULL DEFAULT 0,
    descuento_tardanzas DECIMAL(10, 2) NOT NULL DEFAULT 0,
    otros_descuentos    DECIMAL(10, 2) NOT NULL DEFAULT 0,
    bonificaciones      DECIMAL(10, 2) NOT NULL DEFAULT 0,
    salario_neto        DECIMAL(10, 2) NOT NULL,
    cumplio_horas       BOOLEAN        NOT NULL DEFAULT TRUE,
    fecha_deposito      DATE,
    created_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (planilla_id) REFERENCES planilla (id),
    FOREIGN KEY (empleado_id) REFERENCES empleado (id)
);

-- Índices RRHH
CREATE INDEX idx_empleado_usuario ON empleado (usuario_id);
CREATE INDEX idx_asistencia_empleado_fecha ON asistencia (empleado_id, fecha);
CREATE INDEX idx_justificacion_empleado ON justificacion (empleado_id);
CREATE INDEX idx_planilla_detalle_planilla ON planilla_detalle (planilla_id);
CREATE INDEX idx_planilla_detalle_empleado ON planilla_detalle (empleado_id);
CREATE INDEX idx_planilla_detalle_created_at ON planilla_detalle (created_at);
