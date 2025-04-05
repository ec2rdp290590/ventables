-- Creación de la base de datos para VenTables.com
CREATE DATABASE ventables;

-- Conexión a la base de datos
\c ventables;

-- Tabla de usuarios
CREATE TABLE usuario (
    usuario_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    contrasena_hash VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20) DEFAULT 'cliente', -- cliente, vendedor, admin
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verificado BOOLEAN DEFAULT FALSE,
    calificacion_promedio FLOAT DEFAULT 0,
    foto_perfil VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de categorías
CREATE TABLE categoria (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    imagen VARCHAR(255),
    categoria_padre_id INTEGER REFERENCES categoria(categoria_id)
);

-- Tabla de productos
CREATE TABLE producto (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    vendedor VARCHAR(100) NOT NULL,
    description TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    cantidad_disponible INTEGER NOT NULL,
    disponible_intercambio BOOLEAN DEFAULT FALSE,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    condicion VARCHAR(50),
    envio VARCHAR(100),
    caracteristicas TEXT,
    usuario_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE
);

-- Tabla de relación producto-categoría
CREATE TABLE producto_categoria (
    producto_id INTEGER REFERENCES producto(producto_id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categoria(categoria_id) ON DELETE CASCADE,
    PRIMARY KEY (producto_id, categoria_id)
);

-- Tabla de imágenes de productos
CREATE TABLE producto_imagen (
    imagen_id SERIAL PRIMARY KEY,
    producto_id INTEGER REFERENCES producto(producto_id) ON DELETE CASCADE,
    url_imagen VARCHAR(255) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    descripcion TEXT
);

-- Tabla de valoraciones
CREATE TABLE valoracion (
    valoracion_id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    producto_id INTEGER REFERENCES producto(producto_id) ON DELETE CASCADE,
    usuario_receptor_id INTEGER REFERENCES usuario(usuario_id),
    rating_id INTEGER NOT NULL,
    comentario TEXT,
    fecha_valoracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de direcciones de usuarios
CREATE TABLE usuario_direccion (
    direccion_id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    direccion_linea1 VARCHAR(255) NOT NULL,
    direccion_linea2 VARCHAR(255),
    ciudad VARCHAR(100) NOT NULL,
    estado VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20) NOT NULL,
    pais VARCHAR(100) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE
);

-- Tabla de órdenes/pedidos
CREATE TABLE orden (
    orden_id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(usuario_id) ON DELETE SET NULL,
    direccion_id INTEGER REFERENCES usuario_direccion(direccion_id),
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10, 2) NOT NULL,
    impuestos DECIMAL(10, 2) NOT NULL,
    descuento DECIMAL(10, 2) DEFAULT 0,
    costo_envio DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    estado VARCHAR(50) DEFAULT 'pendiente',
    metodo_pago VARCHAR(50) NOT NULL,
    numero_seguimiento VARCHAR(100)
);

-- Tabla de items de orden
CREATE TABLE item_orden (
    item_orden_id SERIAL PRIMARY KEY,
    orden_id INTEGER REFERENCES orden(orden_id) ON DELETE CASCADE,
    producto_id INTEGER REFERENCES producto(producto_id) ON DELETE SET NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL
);

-- Tabla de transacciones de pago
CREATE TABLE transaccion_pago (
    transaccion_id SERIAL PRIMARY KEY,
    orden_id INTEGER REFERENCES orden(orden_id) ON DELETE SET NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    referencia_pago VARCHAR(255),
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de propuestas de intercambio
CREATE TABLE propuesta_intercambio (
    propuesta_id SERIAL PRIMARY KEY,
    usuario_solicitante_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    usuario_receptor_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    producto_ofrecido_id INTEGER REFERENCES producto(producto_id) ON DELETE CASCADE,
    producto_solicitado_id INTEGER REFERENCES producto(producto_id) ON DELETE CASCADE,
    estado VARCHAR(50) DEFAULT 'pendiente',
    fecha_propuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensaje TEXT
);

-- Tabla de mensajes
CREATE TABLE mensaje (
    mensaje_id SERIAL PRIMARY KEY,
    usuario_emisor_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    usuario_receptor_id INTEGER REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    propuesta_id INTEGER REFERENCES propuesta_intercambio(propuesta_id) ON DELETE SET NULL,
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_producto_usuario ON producto(usuario_id);
CREATE INDEX idx_producto_precio ON producto(precio);
CREATE INDEX idx_valoracion_producto ON valoracion(producto_id);
CREATE INDEX idx_orden_usuario ON orden(usuario_id);
CREATE INDEX idx_item_orden_orden ON item_orden(orden_id);
CREATE INDEX idx_mensaje_receptor ON mensaje(usuario_receptor_id);

-- Funciones y triggers para mantener la integridad de los datos

-- Función para actualizar la calificación promedio del usuario
CREATE OR REPLACE FUNCTION actualizar_calificacion_usuario()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE usuario
    SET calificacion_promedio = (
        SELECT AVG(rating_id)
        FROM valoracion
        WHERE usuario_receptor_id = NEW.usuario_receptor_id
    )
    WHERE usuario_id = NEW.usuario_receptor_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar la calificación después de insertar una valoración
CREATE TRIGGER trigger_actualizar_calificacion
AFTER INSERT OR UPDATE ON valoracion
FOR EACH ROW
EXECUTE FUNCTION actualizar_calificacion_usuario();

-- Función para verificar disponibilidad de producto antes de crear item_orden
CREATE OR REPLACE FUNCTION verificar_disponibilidad_producto()
RETURNS TRIGGER AS $$
DECLARE
    disponible INTEGER;
BEGIN
    SELECT cantidad_disponible INTO disponible
    FROM producto
    WHERE producto_id = NEW.producto_id;
    
    IF disponible < NEW.cantidad THEN
        RAISE EXCEPTION 'No hay suficiente stock disponible para el producto %', NEW.producto_id;
    END IF;
    
    -- Actualizar la cantidad disponible
    UPDATE producto
    SET cantidad_disponible = cantidad_disponible - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar disponibilidad antes de insertar un item_orden
CREATE TRIGGER trigger_verificar_disponibilidad
BEFORE INSERT ON item_orden
FOR EACH ROW
EXECUTE FUNCTION verificar_disponibilidad_producto();
