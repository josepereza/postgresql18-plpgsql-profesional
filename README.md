# Estructura del proyecto

Crea una carpeta para el proyecto y dentro de ella los siguientes archivos:

```text
tienda-docker/
├── docker-compose.yml
└── init/
    └── 01-schema-tienda.sql
```

## 1. El script de inicialización (`init/01-schema-tienda.sql`)

Este archivo contiene exactamente el SQL que proporcionaste. Se ejecutará automáticamente al arrancar el contenedor por primera vez.

```sql
-- 01-schema-tienda.sql
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
('Monitor 27\"', 249.00, 20);

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

> **Nota importante para PostgreSQL 18:** La imagen oficial de PostgreSQL 18 cambió la ubicación del volumen de datos. Ahora el `PGDATA` por defecto es `/var/lib/postgresql/18/docker` y el volumen recomendado a montar es `/var/lib/postgresql` (no `/var/lib/postgresql/data` como en versiones anteriores). El `docker-compose.yml` de abajo ya tiene esto en cuenta.

## 2. El archivo `docker-compose.yml`

```yaml
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
      # Montamos el directorio init para que se ejecute el script al crear la BD
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U tienda_user -d tienda"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

Puntos clave de esta configuración:

- `POSTGRES_DB: tienda`: crea automáticamente la base de datos llamada `tienda`.
- **Volumen de datos:** se monta en `/var/lib/postgresql` (la ruta correcta para PG 18). Así los datos persisten aunque elimines el contenedor.
- **Volumen de inicialización:** `./init:/docker-entrypoint-initdb.d` monta tu carpeta local `init` dentro del contenedor. PostgreSQL ejecutará los archivos `.sql` que encuentre ahí solo si el volumen de datos está vacío (es decir, en la primera ejecución).

## 3. Comandos para levantar y gestionar el entorno

Abre una terminal en la carpeta `tienda-docker/` y ejecuta:

```bash
# Levantar el contenedor en segundo plano
docker compose up -d

# Ver los logs para comprobar que el script de inicialización se ejecutó sin errores
docker compose logs -f postgres
```

Si todo ha ido bien, en los logs verás algo similar a `database system is ready to accept connections`. Para salir de los logs, pulsa `Ctrl+C`.

Conectarse a la base de datos con `psql` desde el host:

```bash
# Entrar al contenedor y abrir una sesión psql en la BD tienda
docker exec -it tienda-postgres psql -U tienda_user -d tienda
```

Una vez dentro, puedes verificar que el esquema y las tablas existen:

```sql
-- Listar esquemas
\dn

-- Cambiar al esquema tienda
SET search_path TO tienda;

-- Listar tablas
\dt

-- Consultar algunos datos
SELECT * FROM clientes;
SELECT * FROM productos;
```

Para salir de `psql`: `\q`.

## 4. Detener y limpiar

```bash
# Detener el contenedor (los datos persisten en el volumen)
docker compose down

# Detener y ELIMINAR el volumen de datos (perderás todo lo que hayas insertado)
docker compose down -v
```

Si en algún momento modificas el archivo `init/01-schema-tienda.sql` y quieres que se vuelva a ejecutar desde cero, necesitas eliminar el volumen de datos (`docker compose down -v`) y volver a levantar (`docker compose up -d`). PostgreSQL solo ejecuta los scripts de inicialización cuando el directorio de datos está vacío.

Con esto tienes un entorno Docker completamente funcional y reproducible para seguir practicando todos los ejemplos de funciones y procedimientos almacenados del tutorial.
