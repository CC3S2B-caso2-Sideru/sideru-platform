-- ============================================
-- Backend DB — Seed Data
-- ============================================

-- Proveedores
INSERT INTO proveedor (ruc, razon_social, contacto, email, telefono, direccion) VALUES
    ('20100070970', 'Aceros Arequipa S.A.',         'Javier Salas',     'ventas@acerosarequipa.com.pe',  '054-380700', 'Av. Enrique Meiggs s/n, Parque Industrial, Arequipa'),
    ('20100017491', 'Corporación Aceros Chilca S.A.','María Quispe',     'mquispe@aceroschi.pe',          '01-3800900', 'Carretera Panamericana Sur km 60, Chilca, Lima'),
    ('20503480264', 'Ferreyros S.A.',               'Luis Pariona',     'lpariona@ferreyros.com.pe',     '01-6146000', 'Av. Argentina 3099, Callao'),
    ('20100007641', 'Sider Perú S.A.',              'Giuliana Mendez',  'gmendez@siderperu.com.pe',      '043-395050', 'Av. Gálvez Chipoco s/n, Chimbote, Áncash');

-- Departamentos
INSERT INTO departamento (nombre) VALUES
    ('Gerencia General'), ('Ventas'), ('Logística y Almacén'),
    ('Recursos Humanos'), ('Administración y Finanzas');

-- Cargos
INSERT INTO cargo (nombre, descripcion, salario_base) VALUES
    ('Gerente General',         'Dirección estratégica de la empresa',        8500.00),
    ('Jefe de Ventas',          'Coordinación del equipo comercial',          4200.00),
    ('Vendedor',                'Atención de clientes y cotizaciones',        2400.00),
    ('Jefe de Almacén',         'Control de stock y logística',               3800.00),
    ('Almacenero',              'Recepción, almacenamiento y despacho',       1800.00),
    ('Administrador de RRHH',   'Gestión de personal y planilla',             3200.00),
    ('Asistente Administrativo','Soporte administrativo y contable',          1900.00);

-- Empleados
INSERT INTO empleado (usuario_id, departamento_id, cargo_id, dni, nombres, apellidos, email, telefono, fecha_ingreso, salario, cuenta_bancaria) VALUES
    (1,  1, 1, '08123456', 'Miguel',    'Torres Salas',      'admin@siderurgicaperu.com',    '01-4561234', '2018-03-01', 8500.00, '00-123-456789'),
    (2,  1, 1, '09234567', 'Patricia',  'Vargas Huamán',     'gerente@siderurgicaperu.com',  '01-4561235', '2019-06-15', 8500.00, '00-123-456790'),
    (3,  2, 3, '10345678', 'Lucía',     'Luna Ccopa',        'vluna@siderurgicaperu.com',    '987001122', '2021-01-10', 2400.00, '00-234-567891'),
    (4,  2, 3, '11456789', 'Marco',     'Ríos Paredes',      'vrios@siderurgicaperu.com',    '987002233', '2021-04-05', 2400.00, '00-234-567892'),
    (5,  3, 4, '12567890', 'Eduardo',   'Huanca Flores',     'ahuanca@siderurgicaperu.com',  '987003344', '2020-07-20', 3800.00, '00-345-678903'),
    (6,  4, 6, '13678901', 'Carmen',    'Mendoza Díaz',      'rmendoza@siderurgicaperu.com', '987004455', '2020-02-01', 3200.00, '00-456-789014'),
    (NULL,2, 2, '14789012', 'Andrés',   'Castillo Vega',     'acastillo@siderurgicaperu.com','987005566', '2017-09-12', 4200.00, '00-234-567893'),
    (NULL,3, 5, '15890123', 'Rocío',    'Apaza Torres',      'rapaza@siderurgicaperu.com',   '987006677', '2022-03-15', 1800.00, '00-345-678904'),
    (NULL,5, 7, '16901234', 'Silvana',  'Campos Ruiz',       'scampos@siderurgicaperu.com',  '987007788', '2023-01-09', 1900.00, '00-567-890125');

/*
 * Cotizaciones con snapshots de producto (producto_sku, producto_nombre).
 * Los IDs de producto (1-21) referencian catalogo_db.producto.id.
 *
 * Mapeo producto_id → (sku, nombre) para backfill:
 *   1  → BAR-COR-6MM,  Varilla corrugada 6mm x 9m
 *   2  → BAR-COR-8MM,  Varilla corrugada 8mm x 9m
 *   3  → BAR-COR-12MM, Varilla corrugada 12mm x 9m
 *   4  → BAR-LIS-16MM, Barra lisa 16mm x 6m
 *   5  → PER-ANG-2X2,  Ángulo 2"x2"x3/16" x 6m
 *   6  → PER-VIG-4,    Viga H 4" x 13lb/pie x 6m
 *   7  → PER-CAN-3,    Canal C 3" x 5lb/pie x 6m
 *   8  → PLA-CAL-2MM,  Plancha laminada caliente 2mm
 *   9  → PLA-GAL-1MM,  Plancha galvanizada 1mm
 *   10 → TUB-NEG-1,    Tubo negro 1" x 6m
 *   11 → TUB-GAL-3_4,  Tubo galvanizado 3/4" x 6m
 *   12 → ALA-REC-16,   Alambre recocido N°16 x 30kg
 *   13 → MAL-ELS-15,   Malla electrosoldada 15x15cm
 *   14 → ACR-BAR-001,  Barra de acero 1/2"
 *   15 → ACR-BAR-002,  Barra de acero 3/4"
 *   16 → TUB-NEG-001,  Tubo negro 2"
 *   17 → TUB-GAL-002,  Tubo galvanizado 1"
 *   18 → PLA-ACE-001,  Plancha de acero 1mm
 *   19 → PLA-ACE-002,  Plancha de acero 3mm
 *   20 → PER-ANG-001,  Ángulo 2x2
 *   21 → PER-CAN-002,  Canal U 3"
 */

-- Cotización 1: cliente Acero Sur — aceptada → tiene pedido
INSERT INTO cotizacion (cliente_id, fecha_emision, fecha_expiracion, estado, subtotal, descuento_total, igv, total) VALUES
    (1, '2025-03-10 09:00:00-05', '2025-03-17', 'aceptada', 3364.00, 168.20, 575.47, 3771.27);

INSERT INTO cotizacion_detalle (cotizacion_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (1, 1, 'BAR-COR-6MM',  'Varilla corrugada 6mm x 9m',         50, 18.50, 5.00,  877.25),
    (1, 2, 'BAR-COR-8MM',  'Varilla corrugada 8mm x 9m',         30, 28.90, 5.00,  822.15),
    (1, 5, 'PER-ANG-2X2',  'Ángulo 2"x2"x3/16" x 6m',            20, 55.00, 5.00, 1045.00),
    (1, 10,'TUB-NEG-1',    'Tubo negro 1" x 6m',                 15, 38.00, 5.00,  541.50);

-- Cotización 2: cliente Construcciones R&M — aceptada → tiene pedido
INSERT INTO cotizacion (cliente_id, fecha_emision, fecha_expiracion, estado, subtotal, descuento_total, igv, total) VALUES
    (2, '2025-03-12 11:30:00-05', '2025-03-19', 'aceptada', 7540.00, 754.00, 1223.46, 8009.46);

INSERT INTO cotizacion_detalle (cotizacion_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (2, 3, 'BAR-COR-12MM', 'Varilla corrugada 12mm x 9m',         60, 58.00, 10.00, 3132.00),
    (2, 6, 'PER-VIG-4',    'Viga H 4" x 13lb/pie x 6m',           15, 195.00,10.00, 2632.50),
    (2, 8, 'PLA-CAL-2MM',  'Plancha laminada caliente 2mm',       10, 210.00,10.00, 1890.00);

-- Cotización 3: cliente Jorge Silva — enviada (pendiente respuesta)
INSERT INTO cotizacion (cliente_id, fecha_emision, fecha_expiracion, estado, subtotal, descuento_total, igv, total) VALUES
    (3, '2025-04-01 14:00:00-05', '2025-04-08', 'enviada', 693.00, 0, 124.74, 817.74);

INSERT INTO cotizacion_detalle (cotizacion_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (3, 11,'TUB-GAL-3_4',  'Tubo galvanizado 3/4" x 6m',         10, 44.00, 0, 440.00),
    (3, 12,'ALA-REC-16',   'Alambre recocido N°16 x 30kg',         1, 98.00, 0,  98.00),
    (3, 1, 'BAR-COR-6MM',  'Varilla corrugada 6mm x 9m',          5, 18.50, 0,  92.50),
    (3, 10,'TUB-NEG-1',    'Tubo negro 1" x 6m',                  1, 38.00, 0,  38.00);

-- Cotización 4: cliente Ferretería JM — rechazada
INSERT INTO cotizacion (cliente_id, fecha_emision, fecha_expiracion, estado, observaciones, subtotal, descuento_total, igv, total) VALUES
    (4, '2025-02-20 10:00:00-05', '2025-02-27', 'rechazada', 'Cliente no aceptó precio de vigas.', 1560.00, 0, 280.80, 1840.80);

INSERT INTO cotizacion_detalle (cotizacion_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (4, 6, 'PER-VIG-4', 'Viga H 4" x 13lb/pie x 6m', 8, 195.00, 0, 1560.00);

-- Cotización 5: cliente Rosa Palacios — borrador
INSERT INTO cotizacion (cliente_id, fecha_emision, fecha_expiracion, estado, subtotal, descuento_total, igv, total) VALUES
    (5, '2025-04-05 16:00:00-05', '2025-04-12', 'borrador', 185.00, 0, 33.30, 218.30);

INSERT INTO cotizacion_detalle (cotizacion_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (5, 9, 'PLA-GAL-1MM', 'Plancha galvanizada 1mm', 1, 185.00, 0, 185.00);

-- Pedidos
INSERT INTO pedido (cotizacion_id, cliente_id, fecha_pedido, estado, total) VALUES
    (1, 1, '2025-03-11 08:30:00-05', 'entregado', 3771.27),
    (2, 2, '2025-03-13 09:00:00-05', 'en_preparacion', 8009.46);

INSERT INTO pedido_detalle (pedido_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (1, 1, 'BAR-COR-6MM',  'Varilla corrugada 6mm x 9m',         50, 18.50, 5.00,  877.25),
    (1, 2, 'BAR-COR-8MM',  'Varilla corrugada 8mm x 9m',         30, 28.90, 5.00,  822.15),
    (1, 5, 'PER-ANG-2X2',  'Ángulo 2"x2"x3/16" x 6m',            20, 55.00, 5.00, 1045.00),
    (1, 10,'TUB-NEG-1',    'Tubo negro 1" x 6m',                 15, 38.00, 5.00,  541.50),
    (2, 3, 'BAR-COR-12MM', 'Varilla corrugada 12mm x 9m',        60, 58.00, 10.00, 3132.00),
    (2, 6, 'PER-VIG-4',    'Viga H 4" x 13lb/pie x 6m',          15, 195.00,10.00, 2632.50),
    (2, 8, 'PLA-CAL-2MM',  'Plancha laminada caliente 2mm',      10, 210.00,10.00, 1890.00);

-- Pedido 3: rechazado por falta de stock
INSERT INTO pedido (cotizacion_id, cliente_id, fecha_pedido, estado, motivo_rechazo, total) VALUES
    (4, 4, '2025-02-21 10:15:00-05', 'rechazado_stock',
     'Stock insuficiente de Viga H 4": disponible 5 unidades, solicitadas 8.',
     1840.80);

INSERT INTO pedido_detalle (pedido_id, producto_id, producto_sku, producto_nombre, cantidad, precio_unitario, descuento, subtotal) VALUES
    (3, 6, 'PER-VIG-4', 'Viga H 4" x 13lb/pie x 6m', 8, 195.00, 0, 1560.00);

-- Comprobantes
INSERT INTO comprobante (pedido_id, tipo, serie, numero, fecha_emision, subtotal, igv, total, estado_pago, fecha_pago, metodo_pago) VALUES
    (1, 'factura', 'F001', '00000001', '2025-03-11 12:00:00-05', 3364.00, 407.27, 3771.27, 'pagado', '2025-03-11 15:30:00-05', 'transferencia'),
    (2, 'factura', 'F001', '00000002', '2025-03-13 10:00:00-05', 7540.00, 469.46, 8009.46, 'pendiente', NULL, 'transferencia');

-- Órdenes de Compra
INSERT INTO orden_compra (proveedor_id, fecha_emision, fecha_estimada, estado, requiere_prestamo, total_estimado, observaciones) VALUES
    (1, '2025-02-22 09:00:00-05', '2025-03-05', 'recibida', FALSE, 9750.00,
     'Reposición urgente de Viga H tras rechazo de pedido #3.');

INSERT INTO orden_compra_detalle (orden_compra_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
    (1, 6, 50, 175.00, 8750.00),
    (1, 7, 10,  70.00, 700.00),
    (1, 8,  1, 140.00, 140.00);

INSERT INTO orden_compra (proveedor_id, fecha_emision, fecha_estimada, estado, requiere_prestamo, total_estimado) VALUES
    (4, '2025-04-02 11:00:00-05', '2025-04-20', 'confirmada', TRUE, 24600.00);

INSERT INTO orden_compra_detalle (orden_compra_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
    (2, 1, 500, 14.00,  7000.00),
    (2, 2, 400, 22.00,  8800.00),
    (2, 3, 150, 44.00,  6600.00),
    (2, 4, 100, 32.00,  3200.00),
    (2, 10,200, 25.00,  5000.00);

-- Recepción de Mercadería
INSERT INTO recepcion_mercaderia (orden_compra_id, fecha_recepcion, observaciones) VALUES
    (1, '2025-03-04 08:00:00-05', 'Mercadería recibida conforme, sin observaciones.');

INSERT INTO recepcion_detalle (recepcion_mercaderia_id, producto_id, cantidad_recibida) VALUES
    (1, 6, 50), (1, 7, 10), (1, 8, 1);

-- Facturas de Proveedor
INSERT INTO factura_proveedor (orden_compra_id, numero_factura, fecha_factura, monto_total, estado_pago, fecha_pago) VALUES
    (1, 'F001-00045231', '2025-03-04', 9750.00, 'pagado', '2025-03-15');

INSERT INTO factura_proveedor (orden_compra_id, numero_factura, fecha_factura, monto_total, estado_pago) VALUES
    (2, 'F001-00048890', '2025-04-02', 24600.00, 'pendiente');

-- Asistencia (Abril 2025)
INSERT INTO asistencia (empleado_id, fecha, tipo, hora, ip_origen) VALUES
    (3, '2025-04-07', 'entrada', '08:02', '192.168.1.10'),
    (3, '2025-04-07', 'salida',  '17:01', '192.168.1.10'),
    (3, '2025-04-08', 'entrada', '08:05', '192.168.1.10'),
    (3, '2025-04-08', 'salida',  '17:00', '192.168.1.10'),
    (3, '2025-04-09', 'entrada', '08:35', '192.168.1.10'),
    (3, '2025-04-09', 'salida',  '17:00', '192.168.1.10'),
    (3, '2025-04-10', 'entrada', '08:01', '192.168.1.10'),
    (3, '2025-04-10', 'salida',  '17:02', '192.168.1.10'),
    (3, '2025-04-11', 'entrada', '08:00', '192.168.1.10'),
    (3, '2025-04-11', 'salida',  '17:00', '192.168.1.10'),
    (5, '2025-04-07', 'entrada', '07:58', '192.168.1.20'),
    (5, '2025-04-07', 'salida',  '17:00', '192.168.1.20'),
    (5, '2025-04-08', 'entrada', '08:00', '192.168.1.20'),
    (5, '2025-04-08', 'salida',  '17:05', '192.168.1.20'),
    (5, '2025-04-10', 'entrada', '08:02', '192.168.1.20'),
    (5, '2025-04-10', 'salida',  '17:00', '192.168.1.20'),
    (5, '2025-04-11', 'entrada', '08:00', '192.168.1.20'),
    (5, '2025-04-11', 'salida',  '17:00', '192.168.1.20'),
    (8, '2025-04-07', 'entrada', '08:00', '192.168.1.30'),
    (8, '2025-04-07', 'salida',  '17:00', '192.168.1.30'),
    (8, '2025-04-08', 'entrada', '08:03', '192.168.1.30'),
    (8, '2025-04-08', 'salida',  '17:00', '192.168.1.30'),
    (8, '2025-04-09', 'entrada', '08:01', '192.168.1.30'),
    (8, '2025-04-09', 'salida',  '17:00', '192.168.1.30'),
    (8, '2025-04-10', 'entrada', '08:00', '192.168.1.30'),
    (8, '2025-04-10', 'salida',  '17:02', '192.168.1.30'),
    (8, '2025-04-11', 'entrada', '08:00', '192.168.1.30'),
    (8, '2025-04-11', 'salida',  '17:00', '192.168.1.30');

-- Justificaciones
INSERT INTO justificacion (empleado_id, fecha_incidencia, tipo_incidencia, descripcion, estado, revisado_por, fecha_revision) VALUES
    (3, '2025-04-09', 'tardanza',
     'Demora por accidente en Av. Javier Prado que bloqueó el tránsito.',
     'aprobada', 6, '2025-04-10 09:00:00-05'),
    (5, '2025-04-09', 'falta',
     'Atención médica de emergencia por infección estomacal.',
     'aprobada', 6, '2025-04-10 10:30:00-05'),
    (8, '2025-04-14', 'tardanza',
     'El reloj marcador presentó falla técnica a las 8:00 am.',
     'pendiente', NULL, NULL);

-- Planilla Marzo 2025
INSERT INTO planilla (periodo, fecha_proceso, procesado_por) VALUES
    ('2025-03', '2025-04-01 10:00:00-05', 6);

INSERT INTO planilla_detalle
(planilla_id, empleado_id, dias_trabajados, dias_falta, dias_tardanza,
 horas_extras, salario_bruto, descuento_faltas, descuento_tardanzas,
 otros_descuentos, bonificaciones, salario_neto, cumplio_horas, fecha_deposito)
VALUES
    (1, 3, 21, 0, 1, 0.00, 2400.00,   0.00,  40.00,   0.00,   0.00, 2360.00, TRUE,  '2025-04-05'),
    (1, 4, 22, 0, 0, 2.00, 2400.00,   0.00,   0.00,   0.00,  60.00, 2460.00, TRUE,  '2025-04-05'),
    (1, 5, 21, 1, 0, 0.00, 3800.00, 172.73,   0.00,   0.00,   0.00, 3627.27, FALSE, '2025-04-05'),
    (1, 6, 22, 0, 0, 0.00, 3200.00,   0.00,   0.00,   0.00,   0.00, 3200.00, TRUE,  '2025-04-05'),
    (1, 7, 22, 0, 0, 4.00, 4200.00,   0.00,   0.00,   0.00, 160.00, 4360.00, TRUE,  '2025-04-05'),
    (1, 8, 22, 0, 0, 0.00, 1800.00,   0.00,   0.00,   0.00,   0.00, 1800.00, TRUE,  '2025-04-05'),
    (1, 9, 20, 0, 2, 0.00, 1900.00,   0.00,  57.58,   0.00,   0.00, 1842.42, FALSE, '2025-04-05');
