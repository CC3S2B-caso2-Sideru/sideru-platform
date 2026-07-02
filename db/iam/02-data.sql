-- ============================================
-- IAM DB — Seed Data
-- Datos extraídos de la DB monolítica original
-- ============================================

-- Roles
INSERT INTO rol (nombre, descripcion) VALUES
    ('admin',      'Administrador general del sistema'),
    ('gerente',    'Gerencia — acceso a reportes y aprobaciones'),
    ('vendedor',   'Gestión de cotizaciones, pedidos y facturación'),
    ('almacenero', 'Control de stock, recepciones y despachos'),
    ('rrhh',       'Recursos humanos: empleados, asistencia y planilla'),
    ('cliente',    'Cliente del portal web');

-- Permisos (formato simplificado: <dominio>.<accion>)
INSERT INTO permiso (codigo, modulo, accion, descripcion) VALUES
    ('cotizacion.ver',       'ventas',    'ver',      'Ver listado y detalle de cotizaciones'),
    ('cotizacion.crear',     'ventas',    'crear',    'Crear nuevas cotizaciones'),
    ('cotizacion.editar',    'ventas',    'editar',   'Editar cotizaciones existentes'),
    ('cotizacion.aprobar',   'ventas',    'aprobar',  'Aprobar o rechazar cotizaciones'),
    ('pedido.ver',           'ventas',    'ver',      'Ver pedidos'),
    ('pedido.crear',         'ventas',    'crear',    'Registrar pedidos'),
    ('pedido.editar',        'ventas',    'editar',   'Actualizar estado de pedidos'),
    ('comprobante.crear',    'ventas',    'crear',    'Emitir facturas y boletas'),
    ('stock.ver',            'logistica', 'ver',      'Consultar stock de productos'),
    ('stock.editar',         'logistica', 'editar',   'Ajustar stock manualmente'),
    ('orden_compra.ver',     'logistica', 'ver',      'Ver órdenes de compra'),
    ('orden_compra.crear',   'logistica', 'crear',    'Crear órdenes de compra'),
    ('recepcion.crear',      'logistica', 'crear',    'Registrar recepciones de mercadería'),
    ('empleado.ver',         'rrhh',      'ver',      'Ver empleados'),
    ('empleado.crear',       'rrhh',      'crear',    'Registrar nuevos empleados'),
    ('asistencia.ver',       'rrhh',      'ver',      'Ver registros de asistencia'),
    ('planilla.ver',         'rrhh',      'ver',      'Ver planillas'),
    ('planilla.procesar',    'rrhh',      'aprobar',  'Procesar planilla mensual'),
    ('reporte.ver',          'reportes',  'ver',      'Acceder a reportes gerenciales'),
    ('usuario.gestionar',    'admin',     'editar',   'Gestionar usuarios y roles');

-- admin: todos los permisos
INSERT INTO rol_permiso (rol_id, permiso_id) SELECT 1, id FROM permiso;

-- gerente
INSERT INTO rol_permiso (rol_id, permiso_id) SELECT 2, id FROM permiso
WHERE codigo IN ('cotizacion.ver','cotizacion.aprobar','pedido.ver','comprobante.crear',
                 'stock.ver','orden_compra.ver','empleado.ver','planilla.ver','reporte.ver');

-- vendedor
INSERT INTO rol_permiso (rol_id, permiso_id) SELECT 3, id FROM permiso
WHERE codigo IN ('cotizacion.ver','cotizacion.crear','cotizacion.editar',
                 'pedido.ver','pedido.crear','pedido.editar','comprobante.crear','stock.ver');

-- almacenero
INSERT INTO rol_permiso (rol_id, permiso_id) SELECT 4, id FROM permiso
WHERE codigo IN ('stock.ver','stock.editar','orden_compra.ver','orden_compra.crear',
                 'recepcion.crear','pedido.ver','pedido.editar');

-- rrhh
INSERT INTO rol_permiso (rol_id, permiso_id) SELECT 5, id FROM permiso
WHERE codigo IN ('empleado.ver','empleado.crear','asistencia.ver','planilla.ver','planilla.procesar');

-- cliente
INSERT INTO rol_permiso (rol_id, permiso_id) SELECT 6, id FROM permiso
WHERE codigo IN ('cotizacion.ver','cotizacion.crear');

-- Usuarios (contraseñas hasheadas con BCrypt del proyecto original)
INSERT INTO usuario (rol_id, tipo, username, email, password_hash) VALUES
    (1, 'INTERNO', 'admin.torres',    'admin@siderurgicaperu.com',     '$2b$12$HASH_ADMIN_001'),
    (2, 'INTERNO', 'gerente.vargas',  'gerente@siderurgicaperu.com',   '$2b$12$HASH_GERE_001'),
    (3, 'INTERNO', 'vendedor.luna',   'vluna@siderurgicaperu.com',     '$2b$12$HASH_VEND_001'),
    (3, 'INTERNO', 'vendedor.rios',   'vrios@siderurgicaperu.com',     '$2b$12$HASH_VEND_002'),
    (4, 'INTERNO', 'almacen.huanca',  'ahuanca@siderurgicaperu.com',   '$2b$12$HASH_ALMA_001'),
    (5, 'INTERNO', 'rrhh.mendoza',    'rmendoza@siderurgicaperu.com',  '$2b$12$HASH_RRHH_001'),
    (6, 'CLIENTE', 'acero_sur',       'compras@acerosur.com.pe',       '$2a$10$GB4LsBTGQo4dVC4lNUNWVePNFcTSsB9H9S.CvJAKq3b.9wtzk6Sri'),
    (6, 'CLIENTE', 'construcciones',  'admin@construccionesrm.pe',     '$2a$10$12YBoiOhIR8nYztvzqs8ge/M633ScKF6Ron2uwelxdrBYbINt.8sW'),
    (6, 'CLIENTE', 'silva',           'jsilva@gmail.com',              '$2a$10$mxBQoHYDxxp1HOx2AgdOs.lh2nVKSHCRVbqA7IwT9WMOEC7Il0.ou'),
    (6, 'CLIENTE', 'ferreteria_jm',   'fjm@ferreteriajesusm.pe',       '$2a$10$XBWyCZ17sd7HpjBWP/dakuGGANEudLmfrY7kT/IeAwS0sR47fXjNG'),
    (6, 'CLIENTE', 'palacios',        'rpalacios@outlook.com',         '$2a$10$TLoldUQeHjEOCIgvjUpA8.3J41G5if5yEy/zCQvyYHYjpCsXgf.Ja');

-- Clientes (IDs 1-5, coinciden con los cliente_id en las cotizaciones de backend_db)
INSERT INTO cliente (usuario_id, ruc, razon_social, nombre, apellido, telefono, direccion) VALUES
    (7,  '20512345678', 'Acero Sur S.A.C.',          'Carlos',  'Delgado',   '01-3451234', 'Av. Industrial 432, Villa El Salvador, Lima'),
    (8,  '20601234567', 'Construcciones R&M E.I.R.L.','Roberto', 'Meza',      '01-2567890', 'Jr. Los Pinos 123, San Juan de Lurigancho, Lima'),
    (9,  NULL,          NULL,                         'Jorge',   'Silva',     '987654321',  'Calle Las Flores 45, Surquillo, Lima'),
    (10, '10345678901', NULL,                         'Fernando','Quispe',    '976543210',  'Av. Grau 890, Trujillo'),
    (11, NULL,          NULL,                         'Rosa',    'Palacios',  '965432109',  'Jr. Amazonas 234, Arequipa');
