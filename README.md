### Proyecto Docker para la base de datos tienda (PostgreSQL 18)
A continuación tienes toda la estructura del proyecto en formato Markdown, lista para copiar y pegar. Se incluye la estructura de carpetas, el script de inicialización, el docker-compose.yml y los comandos para levantar, detener y limpiar el entorno.

📁 Estructura del proyecto
text
tienda-docker/
├── docker-compose.yml
├── README.md
└── init/
    └── 01-schema-tienda.sql
📄 1. docker-compose.yml
yaml
```bash
services:
  postgres:
    image: postgres:18
    container_name: tienda-postgres
    environment:
      POSTGRES_DB: tienda
      POSTGRES_USER: tienda_user
      POSTGRES_PASSWORD: tienda_pass
    ports:
      - "5432:5432"
    volumes:
      # Volumen para persistir los datos (ruta correcta para PG 18)
      - postgres_data:/var/lib/postgresql
      # Directorio de inicialización: se ejecuta al crear la BD por primera vez
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U tienda_user -d tienda"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```
Puntos clave:

POSTGRES_DB: tienda crea automáticamente la base de datos.

El volumen de datos se monta en /var/lib/postgresql (ruta correcta en PostgreSQL 18).

El directorio ./init se monta en /docker-entrypoint-initdb.d; los scripts .sql se ejecutan solo la primera vez que se crea el volumen de datos.

📄 2. init/01-schema-tienda.sql
sql
```

-- ============================================================
-- Script de inicialización de la base de datos "tienda"
-- Se ejecuta automáticamente al crear el contenedor por primera vez
-- ============================================================

CREATE SCHEMA tienda;
SET search_path TO tienda;

-- ------------------------------------------------------------
-- Tabla: clientes
-- ------------------------------------------------------------
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ------------------------------------------------------------
-- Tabla: productos
-- ------------------------------------------------------------
CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- ------------------------------------------------------------
-- Tabla: pedidos
-- ------------------------------------------------------------
CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id),
    fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado TEXT NOT NULL DEFAULT 'pendiente'
);

-- ------------------------------------------------------------
-- Tabla: lineas_pedido
-- ------------------------------------------------------------
CREATE TABLE lineas_pedido (
    linea_id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
    producto_id INTEGER NOT NULL REFERENCES productos(producto_id),
    cantidad INTEGER NOT NULL,
    precio_unit NUMERIC(10,2) NOT NULL
);

-- ------------------------------------------------------------
-- Tabla: pagos
-- ------------------------------------------------------------
CREATE TABLE pagos (
    pago_id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    importe NUMERIC(10,2) NOT NULL,
    metodo TEXT NOT NULL
);

-- ------------------------------------------------------------
-- Tabla: empleados
-- ------------------------------------------------------------
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    salario NUMERIC(10,2) NOT NULL,
    departamento TEXT,
    fecha_contratacion DATE DEFAULT CURRENT_DATE
);

-- ============================================================
-- Datos de ejemplo
-- ============================================================

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
```

📄 3. README.md (opcional pero recomendado)
markdown
# Proyecto Docker - Base de datos "tienda"

Entorno PostgreSQL 18 para practicar funciones y procedimientos almacenados en PL/pgSQL.

## Requisitos
- Docker
- Docker Compose

## Arrancar el entorno
```bash
docker compose up -d
docker compose logs -f postgres
```

## Conectarse a la base de datos
bash
docker exec -it tienda-postgres psql -U tienda_user -d tienda
Dentro de psql:

sql
SET search_path TO tienda;
\dt
SELECT * FROM clientes;
## Detener el entorno (conserva los datos)
bash
docker compose down
## Detener y limpiar TODO (borra los datos)
bash
docker compose down -v
## Re-ejecutar el script de inicialización
El script solo se ejecuta si el volumen está vacío. Para forzar la re-inicialización:

bash
docker compose down -v
docker compose up -d
text




## 🚀 4. Arrancar el entorno

Desde la carpeta `tienda-docker/`:


# Levantar el contenedor en segundo plano
docker compose up -d

# Ver los logs para comprobar que la inicialización terminó correctamente
docker compose logs -f postgres
Salir de los logs con Ctrl+C.

Conectarse a la base de datos:

bash
docker exec -it tienda-postgres psql -U tienda_user -d tienda
Verificar el contenido:

sql
SET search_path TO tienda;
\dn
\dt
SELECT * FROM clientes;
SELECT * FROM productos;
Salir con \q.

🛑 5. Detener y limpiar
### Detener conservando los datos
bash
docker compose down
El volumen postgres_data permanece intacto. Al volver a hacer docker compose up -d, los datos siguen ahí y el script de inicialización NO se vuelve a ejecutar.

### Detener y eliminar TODO (incluidos los datos)
bash
docker compose down -v
Esto elimina el contenedor y el volumen postgres_data. La próxima vez que ejecutes docker compose up -d, PostgreSQL creará la base de datos desde cero y volverá a ejecutar init/01-schema-tienda.sql.

### Re-ejecutar el script de inicialización
Solo hay que hacer:

bash
docker compose down -v
docker compose up -d
Ver el estado del contenedor y del volumen
bash
# Estado del contenedor
docker compose ps

# Volúmenes gestionados por compose
docker volume ls | grep tienda

# Inspeccionar el volumen de datos
docker volume inspect tienda-docker_postgres_data
Eliminar también la imagen (opcional)
bash
docker compose down -v --rmi all
📌 Resumen de comandos
Acción	Comando
Arrancar	docker compose up -d
Ver logs	docker compose logs -f postgres
Conectarse con psql	docker exec -it tienda-postgres psql -U tienda_user -d tienda
Detener conservando datos	docker compose down
Detener y borrar datos	docker compose down -v
Re-inicializar desde cero	docker compose down -v && docker compose up -d
Ver estado	docker compose ps
Ver volúmenes	docker volume ls
Con esto tienes el proyecto completo en Markdown: estructura de carpetas, script de inicialización, docker-compose.yml, README y todos los comandos para arrancar, detener y limpiar el entorno.
