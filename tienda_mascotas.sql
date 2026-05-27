-- =========================================================
-- CREACIÓN DE LA BASE DE DATOS Y CONFIGURACIÓN
-- =========================================================
CREATE DATABASE IF NOT EXISTS tienda_mascotas;
USE tienda_mascotas;

-- =========================================================
-- ESTRUCTURA DE LAS TABLAS (SIN FKs NI PROVEEDORES)
-- =========================================================

-- TABLA USUARIO
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    correo VARCHAR(150) UNIQUE,
    contraseña VARCHAR(255),
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    rol VARCHAR(20) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLA CATEGORIA
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion VARCHAR(200)
);

-- TABLA PRODUCTO
CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150),
    descripcion TEXT,
    precio DECIMAL(10,2),
    stock INT,
    imagen VARCHAR(255),
    id_categoria INT
);

-- TABLA CARRITO
CREATE TABLE carrito (
    id_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DETALLE_CARRITO
CREATE TABLE detalle_carrito (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT,
    id_producto INT,
    cantidad INT,
    subtotal DECIMAL(10,2)
);

-- TABLA PEDIDO
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    estado VARCHAR(50)
);

-- TABLA DETALLE_PEDIDO
CREATE TABLE detalle_pedido (
    id_detalle_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2)
);

-- TABLA PAGO
CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    metodo_pago VARCHAR(50),
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado_pago VARCHAR(50)
);

-- =========================================================
-- AJUSTES Y ALTERACIONES REQUERIDAS
-- =========================================================
ALTER TABLE usuario
CHANGE contraseña password VARCHAR(255);


-- =========================================================
-- PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
-- =========================================================
DELIMITER //

-- 1. USUARIOS: REGISTRO (Rol CLIENTE automático)
CREATE PROCEDURE sp_registrarCliente(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_correo VARCHAR(150),
    IN p_password VARCHAR(255),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(200)
)
BEGIN
    INSERT INTO usuario(nombre, apellido, correo, password, telefono, direccion, rol)
    VALUES(p_nombre, p_apellido, p_correo, p_password, p_telefono, p_direccion, 'CLIENTE');
END //

-- 2. USUARIOS: INICIO DE SESIÓN + (NEW: Datos para Mi Perfil)

DROP PROCEDURE IF EXISTS sp_loginUsuario;

DELIMITER //

CREATE PROCEDURE sp_loginUsuario(
    IN p_correo VARCHAR(150),
    IN p_password VARCHAR(255)
)
BEGIN
    -- Traemos todos los campos (incluyendo password, telefono y direccion)
    SELECT id_usuario, nombre, apellido, correo, password, telefono, direccion, rol 
    FROM usuario 
    WHERE correo = p_correo AND password = p_password;
END //

DELIMITER ;

-- 3. CATEGORÍAS: CREAR
CREATE PROCEDURE sp_crearCategoria(
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(200)
)
BEGIN
    INSERT INTO categoria(nombre, descripcion)
    VALUES(p_nombre, p_descripcion);
END //

-- 4. CATEGORÍAS: EDITAR
CREATE PROCEDURE sp_editarCategoria(
    IN p_id_categoria INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(200)
)
BEGIN
    UPDATE categoria 
    SET nombre = p_nombre, 
        descripcion = p_descripcion
    WHERE id_categoria = p_id_categoria;
END //

-- 5. CATEGORÍAS: ELIMINAR
CREATE PROCEDURE sp_eliminarCategoria(
    IN p_id_categoria INT
)
BEGIN
    DELETE FROM categoria 
    WHERE id_categoria = p_id_categoria;
END //

-- 6. PRODUCTOS: CREAR
CREATE PROCEDURE sp_crearProducto(
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT,
    IN p_imagen VARCHAR(255),
    IN p_id_categoria INT
)
BEGIN
    INSERT INTO producto(nombre, descripcion, precio, stock, imagen, id_categoria)
    VALUES(p_nombre, p_descripcion, p_precio, p_stock, p_imagen, p_id_categoria);
END //

-- 7. PRODUCTOS: EDITAR
CREATE PROCEDURE sp_editarProducto(
    IN p_id_producto INT,
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT,
    IN p_imagen VARCHAR(255),
    IN p_id_categoria INT
)
BEGIN
    UPDATE producto 
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        precio = p_precio,
        stock = p_stock,
        imagen = p_imagen,
        id_categoria = p_id_categoria
    WHERE id_producto = p_id_producto;
END //

-- 8. PRODUCTOS: ELIMINAR
CREATE PROCEDURE sp_eliminarProducto(
    IN p_id_producto INT
)
BEGIN
    DELETE FROM producto 
    WHERE id_producto = p_id_producto;
END //

-- 9. COMPRAS: CREAR CARRITO
CREATE PROCEDURE sp_crearCarrito(IN p_id_usuario INT)
BEGIN
    INSERT INTO carrito(id_usuario)
    VALUES(p_id_usuario);
END //

-- 10. COMPRAS: DETALLE CARRITO
CREATE PROCEDURE sp_agregarDetalleCarrito(IN p_id_carrito INT, IN p_id_producto INT, IN p_cantidad INT, IN p_subtotal DECIMAL(10,2))
BEGIN
    INSERT INTO detalle_carrito(id_carrito, id_producto, cantidad, subtotal)
    VALUES(p_id_carrito, p_id_producto, p_cantidad, p_subtotal);
END //

-- 11. COMPRAS: CREAR PEDIDO
CREATE PROCEDURE sp_crearPedido(IN p_id_usuario INT, IN p_total DECIMAL(10,2), IN p_estado VARCHAR(50))
BEGIN
    INSERT INTO pedido(id_usuario, total, estado)
    VALUES(p_id_usuario, p_total, p_estado);
END //

-- 12. COMPRAS: DETALLE PEDIDO
CREATE PROCEDURE sp_agregarDetallePedido(IN p_id_pedido INT, IN p_id_producto INT, IN p_cantidad INT, IN p_precio_unitario DECIMAL(10,2), IN p_subtotal DECIMAL(10,2))
BEGIN
    INSERT INTO detalle_pedido(id_pedido, id_producto, cantidad, precio_unitario, subtotal)
    VALUES(p_id_pedido, p_id_producto, p_cantidad, p_precio_unitario, p_subtotal);
END //

-- 13. COMPRAS: REGISTRAR PAGO
CREATE PROCEDURE sp_registrarPago(IN p_id_pedido INT, IN p_metodo_pago VARCHAR(50), IN p_estado_pago VARCHAR(50))
BEGIN
    INSERT INTO pago(id_pedido, metodo_pago, estado_pago)
    VALUES(p_id_pedido, p_metodo_pago, p_estado_pago);
END //


-- =========================================================
-- NUEVOS PROCEDURES PARA PUNTOS A, B Y C (SELECTS)
-- =========================================================

-- PUNTO A) Listar todas las categorías
CREATE PROCEDURE sp_listarCategorias()
BEGIN
    SELECT id_categoria, nombre, descripcion 
    FROM categoria;
END //

-- PUNTO B) Listar productos por el ID de una categoría específica
CREATE PROCEDURE sp_buscarProductosPorCategoria(
    IN p_id_categoria INT
)
BEGIN
    SELECT id_producto, nombre, descripcion, precio, stock, imagen, id_categoria 
    FROM producto 
    WHERE id_categoria = p_id_categoria;
END //

-- PUNTO C) Buscar productos por nombre (Búsqueda global flexible con LIKE)
CREATE PROCEDURE sp_buscarProductosPorNombre(
    IN p_nombre_buscar VARCHAR(150)
)
BEGIN
    SELECT id_producto, nombre, descripcion, precio, stock, imagen, id_categoria 
    FROM producto 
    WHERE nombre LIKE CONCAT('%', p_nombre_buscar, '%');
END //

DELIMITER ;

--  ============================
--  Insercion de Categorias
--  ============================

CALL sp_crearCategoria('Alimentos y Nutrición', 'Comida seca, húmeda, snacks y suplementos alimenticios');
CALL sp_crearCategoria('Paseo y Viaje', 'Correas, arneses, transportadoras y seguridad para autos');
CALL sp_crearCategoria('Descanso y Confort', 'Camas, colchonetas, cobijas y casas para mascotas');
CALL sp_crearCategoria('Higiene y Estética', 'Shampoos, cepillos, colonias y cuidado de uñas');
CALL sp_crearCategoria('Juguetes y Entretenimiento', 'Juguetes interactivos, pelotas, rascadores y diversión');
CALL sp_crearCategoria('Salud y Bienestar', 'Antipulgas, vitaminas, arenas sanitarias y cuidado médico');
CALL sp_crearCategoria('Comederos y Accesorios del Hogar', 'Platos, fuentes de agua automáticas y contenedores de comida');

-- =========================================================
-- INSERCIÓN DE PRODUCTOS CON ENFOQUE WEB OPTIMIZADO
-- =========================================================

-- ---------- CATEGORÍA 1: Alimentos y Nutrición (id_categoria = 1) ----------
CALL sp_crearProducto('Royal Canin Mini Adult 3KG', 'Alimento premium equilibrado para perros adultos de razas pequeñas', 165.90, 15, 'royal_mini_adult.jpg', 1);
CALL sp_crearProducto('Pro Plan Gatos Esterilizados Salmon 3KG', 'Fórmula avanzada para el control de peso y salud urinaria en gatos', 178.50, 12, 'proplan_cat_sterilised.jpg', 1);
CALL sp_crearProducto('Lata de Comida Húmeda Hill s Science Diet Perro', 'Estofado premium de pollo y vegetales para digestión sensible', 14.90, 40, 'hills_lata_perro.jpg', 1);
CALL sp_crearProducto('Snacks Funcionales Dentales Twist', 'Premios masticables que ayudan a reducir el sarro y refrescar el aliento', 22.50, 35, 'snacks_dentales_twist.jpg', 1);

-- ---------- CATEGORÍA 2: Paseo y Viaje (id_categoria = 2) ----------
CALL sp_crearProducto('Arnés Ergonómico Reflectante Negro', 'Arnés antitirones acolchado con bandas reflectantes para paseos nocturnos', 65.00, 20, 'arnes_reflectante_negro.jpg', 2);
CALL sp_crearProducto('Correa Retráctil de 5 Metros', 'Correa extensible con sistema de frenado rápido para perros de hasta 25kg', 45.90, 25, 'correa_retractil.jpg', 2);
CALL sp_crearProducto('Mochila Astronauta Expandible para Gatos', 'Mochila con visor de burbuja transparente y ventilación reforzada', 145.50, 8, 'mochila_astronauta_gato.jpg', 2);
CALL sp_crearProducto('Cinturón de Seguridad para Auto', 'Adaptador ajustable para conectar el arnés del perro al broche del vehículo', 24.90, 50, 'cinturon_seguridad_auto.jpg', 2);

-- ---------- CATEGORÍA 3: Descanso y Confort (id_categoria = 3) ----------
CALL sp_crearProducto('Cama Ortopédica Memory Foam L', 'Cama de espuma viscoelástica ideal para el cuidado articular de perros grandes', 189.90, 10, 'cama_ortopedica_l.jpg', 3);
CALL sp_crearProducto('Cuna Acolchada Antiansiedad para Gatos', 'Cama redonda de felpa ultrasuave que simula el pelaje materno', 75.00, 18, 'cuna_antiansiedad_cat.jpg', 3);
CALL sp_crearProducto('Manta Térmica Lavable', 'Manta polar suave ideal para proteger sillones y mantener abrigada a la mascota', 39.90, 30, 'manta_termica.jpg', 3);
CALL sp_crearProducto('Casa Iglú para Gatos y Perros Mini', 'Refugio cerrado de espuma cubierta de tela que brinda privacidad y calor', 85.00, 12, 'casa_iglu_mascota.jpg', 3);

-- ---------- CATEGORÍA 4: Higiene y Estética (id_categoria = 4) ----------
CALL sp_crearProducto('Shampoo Hipoalergénico de Avena 500ml', 'Fórmula suave para mascotas con piel sensible o alergias dermatológicas', 34.90, 22, 'shampoo_avena_sensible.jpg', 4);
CALL sp_crearProducto('Cepillo Deslanador Furminator', 'Herramienta profesional que reduce la caída del pelo hasta en un 90%', 89.90, 15, 'cepillo_deslanador.jpg', 4);
CALL sp_crearProducto('Toallitas Húmedas Sanitarias x100', 'Toallitas gruesas e hidratadas con aloe vera para limpieza de patitas y pelaje', 19.90, 45, 'toallitas_sanitarias.jpg', 4);
CALL sp_crearProducto('Cortaúñas Profesional con Tope de Seguridad', 'Alicate de acero inoxidable con guía para evitar cortes excesivos', 28.50, 20, 'cortaunas_seguridad.jpg', 4);

-- ---------- CATEGORÍA 5: Juguetes y Entretenimiento (id_categoria = 5) ----------
CALL sp_crearProducto('Juguete Rellenable KONG Classic L', 'Juguete de caucho natural ultra resistente para morder y rellenar con premios', 59.90, 30, 'kong_classic_l.jpg', 5);
CALL sp_crearProducto('Rascador de Tres Pisos con Juguete', 'Torre rascadora para gatos con postes de yute, plataformas y pelota colgante', 149.90, 7, 'rascador_tres_pisos.jpg', 5);
CALL sp_crearProducto('Lanzador de Pelotas de Tenis', 'Brazo ergonómico para lanzar pelotas a gran distancia sin cansar el brazo', 26.90, 25, 'lanzador_pelotas.jpg', 5);
CALL sp_crearProducto('Circuito de Juego Interactivo para Gatos', 'Pista con pelota iluminada que se mueve al tacto para estimular el instinto cazador', 54.90, 14, 'circuito_gato_interactivo.jpg', 5);

-- ---------- CATEGORÍA 6: Salud y Bienestar (id_categoria = 6) ----------
CALL sp_crearProducto('Antipulgas y Garrapatas Bravecto Perros 10-20KG', 'Tableta masticable que brinda protección total durante 12 semanas', 145.00, 25, 'bravecto_perro_medium.jpg', 6);
CALL sp_crearProducto('Arena Sanitaria de Bentonita Premium 10KG', 'Arena aglomerante de alta calidad con excelente control de olores', 52.90, 40, 'arena_bentonita_10kg.jpg', 6);
CALL sp_crearProducto('Suplemento Omega 3 y 6 en Aceite 250ml', 'Suplemento líquido para mejorar el brillo del pelaje y la salud del corazón', 48.00, 18, 'omega3_6_suplemento.jpg', 6);
CALL sp_crearProducto('Hierba Gatera (Catnip) en Spray', 'Extracto concentrado para estimular el juego y relajar a los felinos', 22.90, 30, 'catnip_spray.jpg', 6);

-- ---------- CATEGORÍA 7: Comederos y Accesorios del Hogar (id_categoria = 7) ----------
CALL sp_crearProducto('Fuente de Agua Automática con Filtro 2L', 'Dispensador eléctrico tipo cascada que mantiene el agua oxigenada y limpia', 119.90, 10, 'fuente_agua_automatica.jpg', 7);
CALL sp_crearProducto('Plato de Alimentación Lenta (Anti-Ansiedad)', 'Comedero con laberintos internos para evitar que el perro coma demasiado rápido', 35.00, 28, 'plato_alimentacion_lenta.jpg', 7);
CALL sp_crearProducto('Comedero Doble Elevado de Bambú', 'Estructura de madera con dos platos de acero inoxidable para mejorar la postura', 79.90, 12, 'comedero_elevado_bambu.jpg', 7);
CALL sp_crearProducto('Contenedor Hermético para Alimento 15KG', 'Depósito plástico con sello de goma para mantener las croquetas frescas y secas', 69.90, 15, 'contenedor_alimento_15kg.jpg', 7);


-- =========================================================
-- INSERCIÓN DE USUARIOS (ADMINISTRADORES Y CLIENTES)
-- =========================================================

-- ---------- 5 USUARIOS CON ROL: ADMIN ----------
INSERT INTO usuario (nombre, apellido, correo, password, telefono, direccion, rol)
VALUES 
('Jesus', 'Roja', 'adminroja@petshop.com', 'admin123', '920575983', 'Av. Central 456, Lima', 'ADMIN'),
('Ronaldo', 'Nunez', 'adminRN@petshop.com', '123456', '987654321', 'Miraflores, Lima', 'ADMIN'),
('Ramiro', 'Admin', 'adminramiro@petshop.com', 'admin123', '955443322', 'Cercado de Lima', 'ADMIN'),
('Jalit', 'Admin', 'adminjalit@petshop.com', 'admin123', '912345678', 'Miraflores, Lima', 'ADMIN'),
('Josue', 'Espinoza', 'adminjosue@petshop.com', 'admin123', '933221100', 'Callao, Lima', 'ADMIN');


-- ---------- 2 USUARIOS CON ROL: CLIENTE ----------
-- Nota: Usamos el Procedure creado que asigna el rol 'CLIENTE' automáticamente
CALL sp_registrarCliente('Cliente', 'Prueba', 'cliente@petshop.com', 'cliente', '953424555', 'Av. Arequipa 3200, San Isidro, Lima');
CALL sp_registrarCliente('Cliente2', 'Prueba2', 'cliente2@petshop.com', 'cliente2', '953424222', 'Av. Arequipa 3200, San Isidro, Lima');

-- ====================================================================
-- 1. PROCEDIMIENTO PARA LISTAR TODAS LAS CATEGORÍAS ACTIVAS
-- ====================================================================
DROP PROCEDURE IF EXISTS sp_listarCategorias;
DELIMITER //
CREATE PROCEDURE sp_listarCategorias()
BEGIN
    SELECT id_categoria, nombre, estado FROM categoria WHERE estado = 1;
END //
DELIMITER ;

-- ====================================================================
-- 2. PROCEDIMIENTO PARA PRODUCTOS DESTACADOS (POCO STOCK / AL AZAR)
-- ====================================================================
DROP PROCEDURE IF EXISTS sp_listarProductosDestacados;
DELIMITER //
CREATE PROCEDURE sp_listarProductosDestacados()
BEGIN
    -- Muestra los productos con stock menor a 15 unidades primero (Poco Stock / Más buscados)
    SELECT id_producto, nombre, descripcion, precio, stock, imagen, id_categoria 
    FROM producto 
    WHERE stock > 0 
    ORDER BY stock ASC 
    LIMIT 4;
END //
DELIMITER ;

-- ====================================================================
-- 3. PROCEDIMIENTO PARA FILTRAR PRODUCTOS POR CATEGORÍA
-- ====================================================================
DROP PROCEDURE IF EXISTS sp_listarProductosPorCategoria;
DELIMITER //
CREATE PROCEDURE sp_listarProductosPorCategoria(
    IN p_id_categoria INT
)
BEGIN
    -- Si se envía 0, muestra absolutamente todos los productos del PetShop
    IF p_id_categoria = 0 THEN
        SELECT id_producto, nombre, descripcion, precio, stock, imagen, id_categoria 
        FROM producto WHERE stock > 0;
    ELSE
        SELECT id_producto, nombre, descripcion, precio, stock, imagen, id_categoria 
        FROM producto 
        WHERE id_categoria = p_id_categoria AND stock > 0;
    END IF;
END //
DELIMITER ;