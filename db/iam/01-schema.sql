-- ============================================
-- IAM DB — Schema
-- Tablas: rol, permiso, rol_permiso, usuario, cliente
-- ============================================

CREATE TABLE rol
(
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE permiso
(
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(100) NOT NULL UNIQUE,
    modulo      VARCHAR(50)  NOT NULL,
    accion      VARCHAR(50)  NOT NULL,
    descripcion TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE rol_permiso
(
    rol_id     INT         NOT NULL,
    permiso_id INT         NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (rol_id, permiso_id),
    FOREIGN KEY (rol_id) REFERENCES rol (id),
    FOREIGN KEY (permiso_id) REFERENCES permiso (id)
);

CREATE TABLE usuario
(
    id            SERIAL PRIMARY KEY,
    rol_id        INT          NOT NULL,
    tipo          VARCHAR      NOT NULL CHECK (tipo IN ('CLIENTE', 'INTERNO')),
    username      VARCHAR(60)  NOT NULL UNIQUE,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    activo        BOOLEAN               DEFAULT TRUE,
    ultimo_login  TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    FOREIGN KEY (rol_id) REFERENCES rol (id)
);

/*
 * cliente está en la misma DB que usuario porque la relación usuario<->cliente
 * es 1:1 y se usan juntos en cada request autenticado.
 * Los microservicios que necesitan datos de cliente los obtienen vía REST a IAM
 * o desde claims del JWT (clienteId, clienteNombre).
 */
CREATE TABLE cliente
(
    id           SERIAL PRIMARY KEY,
    usuario_id   INT NOT NULL UNIQUE,
    ruc          VARCHAR(11) UNIQUE,
    dni          VARCHAR(8) UNIQUE,
    razon_social VARCHAR(200),
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100),
    telefono     VARCHAR(20),
    direccion    TEXT,
    activo       BOOLEAN               DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    FOREIGN KEY (usuario_id) REFERENCES usuario (id)
);

-- Índices
CREATE INDEX idx_usuario_rol ON usuario (rol_id);
CREATE INDEX idx_cliente_usuario ON cliente (usuario_id);
