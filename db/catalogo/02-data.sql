-- ============================================
-- Catálogo DB — Seed Data
-- Datos extraídos de la DB monolítica original
-- Los IDs de producto (1-25) deben coincidir con
-- producto_id en cotizacion_detalle de backend_db.
-- ============================================

INSERT INTO categoria (nombre, descripcion) VALUES
    ('Barras y Varillas',    'Barras de acero liso y corrugado para construcción'),
    ('Tubos y Cañerías',     'Tubería negra, galvanizada y de acero inoxidable'),
    ('Planchas y Bobinas',   'Planchas laminadas en frío, en caliente y galvanizadas'),
    ('Perfiles Estructurales','Ángulos, vigas, canales y tubos estructurales'),
    ('Alambre y Malla',      'Alambre recocido, malla electrosoldada y gaviones');

INSERT INTO producto (categoria_id, sku, nombre, descripcion, precio, stock, stock_minimo, imagen) VALUES
    (1, 'ACR-BAR-001', 'Barra de acero 1/2"', 'Barra corrugada de 1/2 pulgada', 45.50, 100, 20,
     'https://d34fyu2ua7aizz.cloudfront.net/images/product/24/large/ts_image_5efab149052110_81097952.png'),
    (1, 'ACR-BAR-002', 'Barra de acero 3/4"', 'Barra corrugada de 3/4 pulgada', 70.00, 80, 15,
     'https://d34fyu2ua7aizz.cloudfront.net/images/product/24/large/ts_image_5efab36d826891_21256458.png'),
    (2, 'TUB-NEG-001', 'Tubo negro 2"', 'Tubo de acero negro de 2 pulgadas', 60.00, 50, 10,
     'https://www.sodimac.com.pe/sodimac-pe/articulo/120584782/tubo-redondo-23-5-negro-2-5m/120584784'),
    (2, 'TUB-GAL-002', 'Tubo galvanizado 1"', 'Tubo galvanizado resistente a la corrosión', 55.00, 30, 10,
     'https://ferreteria-laestrella.com/808-large_default/tubo-galvanizado-1-c-40-tramo.jpg'),
    (3, 'PLA-ACE-001', 'Plancha de acero 1mm', 'Plancha delgada de acero', 120.00, 0, 5,
     'https://aba.com.pe/wp-content/uploads/2024/12/naval.png'),
    (3, 'PLA-ACE-002', 'Plancha de acero 3mm', 'Plancha gruesa de acero', 250.00, 20, 5,
     'https://fixmetal.shop/wp-content/uploads/2024/07/PLANCHAS_NAVALES.jpg'),
    (4, 'PER-ANG-001', 'Ángulo 2x2', 'Perfil angular de acero 2x2 pulgadas', 35.00, 60, 15,
     'https://cdn-haoob.nitrocdn.com/DSNuMdcXsYBrEWHsQCEyKvmsrgktJPmJ/assets/images/optimized/rev-f3136ac/www.montanstahl.com/wp-content/uploads/2017/07/L-Mix.jpg'),
    (4, 'PER-CAN-002', 'Canal U 3"', 'Perfil tipo canal U de 3 pulgadas', 90.00, 25, 5,
     'https://www.covema.pe/wp-content/uploads/2019/12/canal-perfilado-hq.jpg'),
    (1, 'BAR-COR-6MM',  'Varilla corrugada 6mm x 9m',   'Acero corrugado grado 60, barra de 9 metros',  18.50,  850, 100),
    (1, 'BAR-COR-8MM',  'Varilla corrugada 8mm x 9m',   'Acero corrugado grado 60, barra de 9 metros',  28.90,  620, 100),
    (1, 'BAR-COR-12MM', 'Varilla corrugada 12mm x 9m',  'Acero corrugado grado 60, barra de 9 metros',  58.00,  430,  80),
    (1, 'BAR-LIS-16MM', 'Barra lisa 16mm x 6m',         'Acero liso SAE 1020, barra de 6 metros',       42.00,  200,  50),
    (2, 'PER-ANG-2X2',  'Ángulo 2"x2"x3/16" x 6m',     'Ángulo de acero A36',                         55.00,  310,  60),
    (2, 'PER-VIG-4',    'Viga H 4" x 13lb/pie x 6m',   'Viga de acero estructural A36',               195.00,  120,  30),
    (2, 'PER-CAN-3',    'Canal C 3" x 5lb/pie x 6m',   'Canal de acero A36',                           88.00,  180,  40),
    (3, 'PLA-CAL-2MM',  'Plancha laminada caliente 2mm','Plancha LAC 1.22m x 2.44m',                   210.00,  95,  20),
    (3, 'PLA-GAL-1MM',  'Plancha galvanizada 1mm',      'Plancha galvanizada 1.22m x 2.44m, Z275',    185.00,  140,  25),
    (4, 'TUB-NEG-1',    'Tubo negro 1" x 6m',           'Tubo negro ERW ASTM A53',                      38.00,  500,  80),
    (4, 'TUB-GAL-3_4',  'Tubo galvanizado 3/4" x 6m',  'Tubo galvanizado ASTM A53',                    44.00,  380,  80),
    (5, 'ALA-REC-16',   'Alambre recocido N°16 x 30kg', 'Rollo de alambre recocido calibre 16',         98.00,  220,  50),
    (5, 'MAL-ELS-15',   'Malla electrosoldada 15x15cm', 'Panel 2.4m x 6m, alambre 4mm',               145.00,   75,  20);
