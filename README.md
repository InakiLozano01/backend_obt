# API Sistema de Cine

API RESTful para gestión de reservas de cine desarrollada con Flask, siguiendo arquitectura **Controller-Service-Repository**.

## 📋 Tabla de Contenidos

- [Arquitectura](#arquitectura)
- [Requisitos Previos](#requisitos-previos)
- [Instalación y Configuración](#instalación-y-configuración)
  - [Opción A: Con Docker (Recomendado)](#opción-a-con-docker-recomendado)
  - [Opción B: Sin Docker (Ejecución Local)](#opción-b-sin-docker-ejecución-local)
- [Configuración de Base de Datos](#configuración-de-base-de-datos)
- [Variables de Entorno](#variables-de-entorno)
- [Uso de la API](#uso-de-la-api)
- [Endpoints Disponibles](#endpoints-disponibles)
- [Ejemplos de Llamadas](#ejemplos-de-llamadas)
- [Stored Procedures](#stored-procedures)
- [Solución de Problemas](#solución-de-problemas)
- [Tecnologías](#tecnologías)

---

## 🏗️ Arquitectura

```
app/
├── controllers/     # Capa HTTP (requests/responses + Swagger)
├── services/        # Lógica de negocio
├── repositories/    # Acceso a datos vía Stored Procedures
├── models/          # Entidades Pydantic
├── schemas/         # DTOs request/response
└── utils/           # Paginación, excepciones
```

---

## 📦 Requisitos Previos

### Para Docker:

- Docker Desktop (Windows/Mac) o Docker Engine (Linux)
- Docker Compose v2 (incluido en Docker Desktop)

### Para Ejecución Local:

- Python 3.12 o superior
- MySQL 8.0 o superior (o Percona Server 8.0)
- pip (gestor de paquetes de Python)

---

## 🚀 Instalación y Configuración

### Opción A: Con Docker (Recomendado)

#### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd backend_obt
```

#### 2. Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp env.example .env

# Editar .env con tus credenciales (opcional, los valores por defecto funcionan)
```

#### 3. Iniciar los Servicios

```bash
# Construir e iniciar todos los servicios (MySQL + Flask)
docker compose up --build

# O en modo detached (segundo plano)
docker compose up -d --build
```

#### 4. Verificar que Todo Funciona

```bash
# Ver logs de MySQL
docker compose logs mysql

# Ver logs de Flask
docker compose logs flask_app

# Ver logs del servicio de inicialización
docker compose logs mysql-init

# Verificar que la API responde
curl http://localhost:5000/swagger/
```

#### 5. Acceder a la API

- **API Base**: http://localhost:5000/api/v1
- **Swagger UI**: http://localhost:5000/swagger/

#### Comandos Útiles de Docker

```bash
# Detener todos los servicios
docker compose down

# Detener y eliminar volúmenes (¡CUIDADO: borra los datos!)
docker compose down -v

# Reiniciar un servicio específico
docker compose restart mysql

# Ver estado de los servicios
docker compose ps

# Ejecutar comandos dentro del contenedor MySQL
docker compose exec mysql bash

# Ejecutar comandos dentro del contenedor Flask
docker compose exec flask_app bash
```

---

### Opción B: Sin Docker (Ejecución Local)

#### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd backend_obt
```

#### 2. Crear Entorno Virtual

```bash
# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate
```

#### 3. Instalar Dependencias

```bash
pip install -r requirements.txt
```

#### 4. Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp env.example .env

# Editar .env con tus credenciales locales
# IMPORTANTE: Cambiar DATABASE_HOST a 'localhost' o '127.0.0.1'
```

Editar `.env` y cambiar:

```env
DATABASE_HOST=localhost  # O 127.0.0.1
DATABASE_PORT=3306      # Puerto de tu MySQL local
```

#### 5. Configurar Base de Datos MySQL Local

Ver sección [Configuración de Base de Datos](#configuración-de-base-de-datos) más abajo.

#### 6. Ejecutar la Aplicación

```bash
# Opción 1: Usando Python directamente
python app.py

# Opción 2: Usando Flask CLI
flask run --host=0.0.0.0 --port=5000

# Opción 3: Con modo debug
FLASK_DEBUG=1 flask run --host=0.0.0.0 --port=5000
```

#### 7. Verificar que Funciona

```bash
# Debe retornar la documentación Swagger
curl http://localhost:5000/swagger/
```

---

## 🗄️ Configuración de Base de Datos

### Con Docker (Automático)

Los scripts SQL se ejecutan automáticamente cuando MySQL se inicia por primera vez o cuando se reinicia el contenedor `mysql-init`.

**Archivos involucrados:**

- `init_db.sql`: Crea la base de datos, tablas, índices y stored procedures
- `seed_db.sql`: Trunca las tablas e inserta datos de prueba
- `init-mysql.sh`: Script que ejecuta ambos SQL cuando MySQL está listo

**Comportamiento:**

- **Primera inicialización**: MySQL ejecuta automáticamente los scripts en `/docker-entrypoint-initdb.d/`
- **Reinicios**: El servicio `mysql-init` ejecuta los scripts cada vez que MySQL se reinicia

**⚠️ ADVERTENCIA**: El script `init_db.sql` ejecuta `DROP DATABASE IF EXISTS`, lo que **eliminará todos los datos** existentes. Esto es intencional para tener una base de datos limpia.

**Controlar la inicialización automática:**

Para deshabilitar la ejecución automática en reinicios, edita `.env`:

```env
INIT_ON_RESTART=false
```

### Sin Docker (Manual)

#### 1. Crear Base de Datos

```bash
# Conectarse a MySQL
mysql -u root -p

# O si tienes usuario específico
mysql -u tu_usuario -p
```

#### 2. Ejecutar Scripts SQL

```sql
-- Opción 1: Desde MySQL CLI
source /ruta/completa/a/init_db.sql;
source /ruta/completa/a/seed_db.sql;

-- Opción 2: Desde línea de comandos
mysql -u root -p < init_db.sql
mysql -u root -p < seed_db.sql
```

#### 3. Verificar Creación

```sql
USE cine_db;

-- Verificar tablas
SHOW TABLES;
-- Resultado esperado: Butacas, Funciones, Generos, Peliculas, Reservas, Salas

-- Verificar stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'cine_db';
-- Resultado esperado:
-- SP_DeterminarPrecioEntrada
-- SP_ReporteOcupacionPorPelicula
-- SP_ReservarButacaConValidacionDNI
-- SP_ReservasPorDNI
```

---

## 🔧 Variables de Entorno

Copia `env.example` a `.env` y configura las siguientes variables:

### Variables de MySQL

| Variable              | Descripción                 | Valor por Defecto | Notas                                           |
| --------------------- | --------------------------- | ----------------- | ----------------------------------------------- |
| `MYSQL_ROOT_PASSWORD` | Contraseña del usuario root | `rootpassword`    | Solo para Docker                                |
| `MYSQL_DATABASE`      | Nombre de la base de datos  | `cine_db`         | Solo para Docker                                |
| `MYSQL_USER`          | Usuario de la base de datos | `app_user`        | Solo para Docker                                |
| `MYSQL_PASSWORD`      | Contraseña del usuario      | `app_password`    | Solo para Docker                                |
| `MYSQL_PORT`          | Puerto externo de MySQL     | `3306`            | Solo para Docker, cambiar si tienes MySQL local |

### Variables de Flask

| Variable      | Descripción                            | Valor por Defecto |
| ------------- | -------------------------------------- | ----------------- |
| `FLASK_APP`   | Archivo principal de la aplicación     | `app.py`          |
| `FLASK_ENV`   | Entorno de ejecución                   | `development`     |
| `FLASK_DEBUG` | Modo debug (1=activado, 0=desactivado) | `1`               |
| `FLASK_PORT`  | Puerto de la API                       | `5000`            |
| `SECRET_KEY`  | Clave secreta para sesiones            | `dev-secret-key`  |

### Variables de Conexión a Base de Datos

| Variable            | Descripción      | Valor por Defecto | Notas                                          |
| ------------------- | ---------------- | ----------------- | ---------------------------------------------- |
| `DATABASE_HOST`     | Host de MySQL    | `mysql`           | En Docker usar `mysql`, local usar `localhost` |
| `DATABASE_PORT`     | Puerto de MySQL  | `3306`            | Puerto interno en Docker, externo en local     |
| `DATABASE_NAME`     | Nombre de la BD  | `cine_db`         | Debe coincidir con `MYSQL_DATABASE`            |
| `DATABASE_USER`     | Usuario de BD    | `app_user`        | Debe coincidir con `MYSQL_USER`                |
| `DATABASE_PASSWORD` | Contraseña de BD | `app_password`    | Debe coincidir con `MYSQL_PASSWORD`            |

### Variables Opcionales

| Variable          | Descripción                                    | Valor por Defecto |
| ----------------- | ---------------------------------------------- | ----------------- |
| `INIT_ON_RESTART` | Ejecutar scripts SQL en cada reinicio (Docker) | `true`            |

**Ejemplo de `.env` para Docker:**

```env
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=cine_db
MYSQL_USER=app_user
MYSQL_PASSWORD=app_password
MYSQL_PORT=3306

FLASK_APP=app.py
FLASK_ENV=development
FLASK_DEBUG=1
FLASK_PORT=5000
SECRET_KEY=dev-secret-key

DATABASE_HOST=mysql
DATABASE_PORT=3306
DATABASE_NAME=cine_db
DATABASE_USER=app_user
DATABASE_PASSWORD=app_password

INIT_ON_RESTART=true
```

**Ejemplo de `.env` para ejecución local:**

```env
FLASK_APP=app.py
FLASK_ENV=development
FLASK_DEBUG=1
FLASK_PORT=5000
SECRET_KEY=dev-secret-key

DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=cine_db
DATABASE_USER=app_user
DATABASE_PASSWORD=app_password
```

---

## 📡 Uso de la API

### Acceder a la Documentación Swagger

Una vez que la aplicación esté ejecutándose, accede a:

**http://localhost:5000/swagger/**

Aquí encontrarás:

- Documentación interactiva de todos los endpoints
- Posibilidad de probar los endpoints directamente desde el navegador
- Esquemas de request/response
- Códigos de estado HTTP

---

## 🔌 Endpoints Disponibles

| Método | Endpoint                      | Descripción                             |
| ------ | ----------------------------- | --------------------------------------- |
| GET    | `/api/v1/precios/{idFuncion}` | Obtener precio calculado de una función |
| GET    | `/api/v1/reporte/ocupacion`   | Reporte de ocupación por película       |
| POST   | `/api/v1/reservas`            | Crear nueva reserva                     |
| GET    | `/api/v1/reservas/{dni}`      | Listar reservas por DNI                 |

---

## 📝 Ejemplos de Llamadas

### GET /precios/{idFuncion}

Obtiene el precio calculado de una función con recargos aplicados.

**cURL:**

```bash
curl -X GET "http://localhost:5000/api/v1/precios/1" \
  -H "Accept: application/json"
```

**Respuesta exitosa (200):**

```json
{
  "id_funcion": 1,
  "precio_final": 115.5,
  "mensaje": "OK"
}
```

**Respuesta error (404):**

```json
{
  "message": "Funcion no encontrada"
}
```

---

### GET /reporte/ocupacion

Genera reporte de ocupación por película en un rango de fechas.

**cURL:**

```bash
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=2025-01-01&fechaFin=2025-12-31&page=1&per_page=10" \
  -H "Accept: application/json"
```

**Parámetros de consulta:**

- `idPelicula` (requerido): ID de la película
- `fechaInicio` (requerido): Fecha inicio (formato YYYY-MM-DD)
- `fechaFin` (requerido): Fecha fin (formato YYYY-MM-DD)
- `page` (opcional): Número de página (default: 1)
- `per_page` (opcional): Elementos por página (default: 10, max: 100)

**Respuesta exitosa (200):**

```json
{
  "data": [
    {
      "IdFuncion": 1,
      "FechaInicio": "2025-12-15T20:00:00",
      "IdSala": 1,
      "Sala": "Sala VIP",
      "TotalButacasVendidas": 45,
      "TotalIngresosRecaudados": 5175.0
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 1,
    "total_pages": 1,
    "has_next": false,
    "has_prev": false
  }
}
```

---

### POST /reservas

Crea una nueva reserva con validación de DNI.

**cURL:**

```bash
curl -X POST "http://localhost:5000/api/v1/reservas" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "id_funcion": 1,
    "id_butaca": 5,
    "dni": "12345678"
  }'
```

**Body (JSON):**

```json
{
  "id_funcion": 1,
  "id_butaca": 5,
  "dni": "12345678"
}
```

**Validaciones:**

- `id_funcion`: Debe ser un entero mayor que 0
- `id_butaca`: Debe ser un entero mayor que 0
- `dni`: Debe ser un string entre 7 y 11 caracteres

**Respuesta exitosa (201):**

```json
{
  "success": true,
  "mensaje": "Reserva creada exitosamente"
}
```

**Respuestas de error:**

_Datos inválidos (400):_

```json
{
  "message": "Datos invalidos: id_funcion: ensure this value is greater than 0"
}
```

_Función no encontrada (404):_

```json
{
  "message": "Funcion no encontrada"
}
```

_Butaca ya reservada (409):_

```json
{
  "message": "Butaca ya reservada para esta funcion"
}
```

_Límite de reservas excedido (409):_

```json
{
  "message": "Limite de 4 reservas activas y pagadas por fecha superado para este DNI"
}
```

---

### GET /reservas/{dni}

Lista todas las reservas de un cliente por DNI.

**cURL:**

```bash
curl -X GET "http://localhost:5000/api/v1/reservas/12345678?page=1&per_page=10" \
  -H "Accept: application/json"
```

**Parámetros de consulta:**

- `page` (opcional): Número de página (default: 1)
- `per_page` (opcional): Elementos por página (default: 10, max: 100)

**Respuesta exitosa (200):**

```json
{
  "data": [
    {
      "IdReserva": 1,
      "DNI": "12345678",
      "IdFuncion": 1,
      "FechaInicio": "2025-12-15T20:00:00",
      "Pelicula": "Avatar 3",
      "Sala": "Sala VIP",
      "EstaPagada": "S",
      "FechaAlta": "2025-12-01T10:30:00",
      "FechaBaja": null
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 1,
    "total_pages": 1,
    "has_next": false,
    "has_prev": false
  }
}
```

---

## 📊 Códigos de Error HTTP

| Código | Descripción  | Ejemplo                             |
| ------ | ------------ | ----------------------------------- |
| 200    | OK           | Consulta exitosa                    |
| 201    | Created      | Reserva creada exitosamente         |
| 400    | Bad Request  | Datos inválidos, función inactiva   |
| 404    | Not Found    | Función/butaca no encontrada        |
| 409    | Conflict     | Butaca ocupada, límite DNI excedido |
| 500    | Server Error | Error interno del servidor          |

---

## 🗃️ Stored Procedures

La aplicación utiliza Stored Procedures de MySQL para la lógica de negocio. Puedes ejecutarlos manualmente para pruebas:

### SP_DeterminarPrecioEntrada

Calcula el precio final de una función con recargos aplicados.

**Reglas de precio:**

- Género "Estreno" o "3D": +10%
- Sala VIP (IdSala=1): +5%
- Ambos recargos se combinan (multiplicativos)

```sql
-- Llamar al SP
CALL SP_DeterminarPrecioEntrada(1, @precio, @mensaje);

-- Ver resultados
SELECT @precio AS PrecioFinal, @mensaje AS Mensaje;
```

### SP_ReporteOcupacionPorPelicula

Genera reporte de ocupación por película en un rango de fechas.

```sql
CALL SP_ReporteOcupacionPorPelicula(1, '2025-01-01', '2025-12-31');
```

### SP_ReservarButacaConValidacionDNI

Crea una reserva validando todas las reglas de negocio:

- Función existe y está activa
- Butaca existe y pertenece a la sala de la función
- Butaca no está ya reservada
- Límite de 4 reservas activas y pagadas por DNI por fecha

```sql
-- Llamar al SP
CALL SP_ReservarButacaConValidacionDNI(1, 5, '12345678', @mensaje);

-- Ver resultado
SELECT @mensaje AS Mensaje;
```

### SP_ReservasPorDNI

Lista todas las reservas de un cliente por DNI.

```sql
CALL SP_ReservasPorDNI('12345678');
```

---

## 🔍 Solución de Problemas

### Problemas con Docker

#### Los scripts SQL no se ejecutan

1. **Verificar que los archivos estén montados:**

   ```bash
   docker compose exec mysql ls -la /docker-entrypoint-initdb.d/
   ```

2. **Ver logs de MySQL:**

   ```bash
   docker compose logs mysql
   ```

3. **Ver logs del servicio de inicialización:**

   ```bash
   docker compose logs mysql-init
   ```

4. **Ejecutar scripts manualmente:**
   ```bash
   # Desde el host
   docker compose exec -T mysql mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < init_db.sql
   docker compose exec -T mysql mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < seed_db.sql
   ```

#### Error: "Database already exists"

Esto es normal. El script `init_db.sql` usa `DROP DATABASE IF EXISTS`, así que debería funcionar correctamente. Si persiste el error, verifica los logs.

#### Error: "Access denied"

1. Verifica que las credenciales en `.env` sean correctas
2. Verifica que `MYSQL_ROOT_PASSWORD` esté configurado
3. Verifica que el usuario tenga permisos suficientes

#### El contenedor MySQL no inicia

1. Verifica que el puerto 3306 no esté en uso:

   ```bash
   # Windows
   netstat -ano | findstr :3306

   # Linux/Mac
   lsof -i :3306
   ```

2. Cambia el puerto en `.env`:
   ```env
   MYSQL_PORT=3307
   ```

#### Flask no se conecta a MySQL

1. Verifica que MySQL esté saludable:

   ```bash
   docker compose ps
   ```

2. Verifica las variables de entorno:

   ```bash
   docker compose exec flask_app env | grep DATABASE
   ```

3. Verifica la conectividad:
   ```bash
   docker compose exec flask_app ping mysql
   ```

### Problemas sin Docker

#### Error de conexión a MySQL

1. Verifica que MySQL esté ejecutándose:

   ```bash
   # Windows
   net start MySQL80

   # Linux
   sudo systemctl status mysql

   # Mac
   brew services list
   ```

2. Verifica las credenciales en `.env`
3. Verifica que `DATABASE_HOST` sea `localhost` o `127.0.0.1`
4. Verifica que el puerto sea correcto (default: 3306)

#### Error: "Module not found"

1. Asegúrate de tener el entorno virtual activado
2. Instala las dependencias:
   ```bash
   pip install -r requirements.txt
   ```

#### Error al ejecutar scripts SQL

1. Verifica que tengas permisos para crear bases de datos
2. Verifica que MySQL esté ejecutándose
3. Ejecuta los scripts manualmente desde MySQL CLI

---

## 🛠️ Tecnologías

- **Python 3.12** - Lenguaje de programación
- **Flask 3.0** - Framework web
- **Flask-RESTX** - Documentación Swagger/OpenAPI
- **Pydantic 2.5** - Validación de datos (ver [PYDANTIC.md](PYDANTIC.md))
- **PyMySQL** - Conector MySQL para Python
- **MySQL 8 Percona** - Base de datos
- **Docker** - Contenedores
- **Docker Compose v2** - Orquestación de contenedores

---

## 📚 Documentación Adicional

- [PYDANTIC.md](PYDANTIC.md) - Documentación sobre el uso de Pydantic en el proyecto
- [init_db.sql](init_db.sql) - Script de creación de base de datos
- [seed_db.sql](seed_db.sql) - Script de datos de prueba

---

## 📄 Licencia

Ver archivo [LICENSE](LICENSE) para más detalles.
