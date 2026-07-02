-- ============================================
-- Catálogo DB — Schema
-- Tablas: categoria, producto
-- ============================================

CREATE TABLE categoria
(
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE producto
(
    id           SERIAL PRIMARY KEY,
    categoria_id INT                NOT NULL,
    sku          VARCHAR(50) UNIQUE NOT NULL,
    nombre       VARCHAR(150)       NOT NULL,
    descripcion  TEXT,
    imagen       TEXT,
    precio       DECIMAL(10, 2)     NOT NULL,
    stock        INT                NOT NULL DEFAULT 0,
    /*
     * stock_minimo tiene doble función:
     * 1. Umbral de alerta de stock bajo (Logística)
     * 2. Umbral de auto-aprobación de cotizaciones (Ventas):
     *    si cantidad <= stock_minimo en todos los items →
     *    cotización auto-aceptada sin revisión manual.
     */
    stock_minimo INT                         DEFAULT 0,
    activo       BOOLEAN                     DEFAULT TRUE,
    created_at   TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    FOREIGN KEY (categoria_id) REFERENCES categoria (id)
);
