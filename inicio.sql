CREATE SCHEMA tienda;
SET search_path TO tienda;
CREATE TABLE clientes (
cliente_id SERIAL PRIMARY KEY,
nombre TEXT NOT NULL,
email TEXT UNIQUE NOT NULL,
fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE
);
CREATE TABLE productos (
producto_id SERIAL PRIMARY KEY,
nombre TEXT NOT NULL,
precio NUMERIC(10,2) NOT NULL,
stock INTEGER NOT NULL DEFAULT 0,
activo BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE pedidos (
pedido_id SERIAL PRIMARY KEY,
cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id),
fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
estado TEXT NOT NULL DEFAULT 'pendiente'
);
CREATE TABLE lineas_pedido (
linea_id SERIAL PRIMARY KEY,
pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
producto_id INTEGER NOT NULL REFERENCES productos(producto_id),
cantidad INTEGER NOT NULL,
precio_unit NUMERIC(10,2) NOT NULL
);
CREATE TABLE pagos (
pago_id SERIAL PRIMARY KEY,
pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
importe NUMERIC(10,2) NOT NULL,
metodo TEXT NOT NULL
);
CREATE TABLE empleados (
id SERIAL PRIMARY KEY,
nombre TEXT NOT NULL,
salario NUMERIC(10,2) NOT NULL,
departamento TEXT,
fecha_contratacion DATE DEFAULT CURRENT_DATE
);
INSERT INTO empleados (nombre, salario, departamento) VALUES
('Ana Torres', 2800.00, 'Ventas'),
('Luis Martínez', 4500.00, 'IT'),
('Carla Gómez', 5200.00, 'IT'),
('Dmitry Komarov', 3100.00, 'Contabilidad'),
('James Smith', 7000.00, 'Dirección'),
('Mary Sexton', 3900.00, 'Marketing'),
('Agnes Miller', 6100.00, 'IT'),
('Chun Yen', 2950.00, 'Ventas');
INSERT INTO clientes (nombre, email) VALUES
('Juan Pérez', 'juan@example.com'),
('María López', 'maria@example.com');
INSERT INTO productos (nombre, precio, stock) VALUES
('Teclado mecánico', 79.90, 50),
('Ratón inalámbrico', 39.50, 100),
('Monitor 27"', 249.00, 20);
INSERT INTO pedidos (cliente_id, estado) VALUES
(1, 'pendiente'),
(2, 'pendiente');
INSERT INTO lineas_pedido (pedido_id, producto_id, cantidad, precio_unit) VALUES
(1, 1, 1, 79.90),
(1, 2, 2, 39.50),
(2, 3, 1, 249.00);
INSERT INTO pagos (pedido_id, importe, metodo) VALUES
(1, 158.90, 'tarjeta'),
(2, 249.00, 'transferencia');
