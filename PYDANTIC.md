# Uso de Pydantic en el Repositorio

## ¿Qué es Pydantic y por qué lo usamos?

Pydantic es una biblioteca de Python que proporciona validación de datos usando anotaciones de tipo. En este repositorio, usamos Pydantic para múltiples propósitos que mejoran la calidad, seguridad y mantenibilidad del código.

---

## 1. Validación Automática de Datos de Entrada (Schemas)

### Ubicación: `app/schemas/`

Los schemas de Pydantic se usan para validar datos de entrada y salida de la API.

### Beneficios:

#### ✅ Validación Automática
Cuando recibimos datos del cliente (`request.json`), Pydantic valida automáticamente:
- **Tipos de datos** (int, str, datetime, Decimal, etc.)
- **Valores requeridos vs opcionales**
- **Reglas de negocio** (gt=0, min_length, max_length, etc.)

**Ejemplo práctico:**
```python
# En reserva_controller.py
data = ReservaCreate(**request.json)
```

Esto valida automáticamente que:
- `id_funcion` sea un int > 0
- `id_butaca` sea un int > 0  
- `dni` sea un string entre 7 y 11 caracteres

Si alguna validación falla, Pydantic lanza `ValidationError` con mensajes claros que convertimos en respuesta HTTP 400.

**Sin Pydantic tendríamos que escribir:**
```python
if not isinstance(id_funcion, int) or id_funcion <= 0:
    raise ValueError("id_funcion debe ser un entero mayor que 0")
if not dni or len(dni) < 7 or len(dni) > 11:
    raise ValueError("dni debe tener entre 7 y 11 caracteres")
# ... y así para cada campo
```

#### ✅ Documentación Automática
- Los schemas pueden generar automáticamente documentación OpenAPI/Swagger
- Los ejemplos en `Config.json_schema_extra` aparecen en la documentación de la API
- Los desarrolladores pueden ver exactamente qué datos esperar sin leer código

#### ✅ Conversión y Transformación de Datos
- Pydantic convierte automáticamente tipos (ej: string a int, string a datetime)
- Usamos `alias` para mapear nombres de la base de datos (`IdReserva`) a nombres Python (`id_reserva`)
- `populate_by_name=True` permite usar ambos nombres (snake_case y PascalCase)

**Ejemplo con alias:**
```python
class ReservaDetalle(BaseModel):
    id_reserva: int = Field(..., alias="IdReserva")
    dni: str = Field(..., alias="DNI")
    
    class Config:
        populate_by_name = True  # Permite usar ambos: id_reserva o IdReserva
```

#### ✅ Seguridad y Robustez
- Previene errores de tipo que podrían causar bugs en producción
- Valida datos antes de que lleguen a la lógica de negocio
- Reduce la superficie de ataque al rechazar datos malformados temprano

#### ✅ Mantenibilidad
- Los schemas centralizan la definición de estructuras de datos
- Si cambia la estructura, solo actualizamos el schema, no múltiples lugares
- Facilita el testing: podemos crear instancias válidas fácilmente

---

## 2. Schemas de Respuesta

### Ubicación: `app/schemas/precio.py`, `app/schemas/reserva.py`, etc.

Aunque Flask-RESTx también tiene modelos para respuestas, usar Pydantic para schemas de respuesta nos da beneficios adicionales:

#### ✅ Consistencia en Toda la Aplicación
- Usamos Pydantic tanto para entrada como salida, manteniendo un patrón uniforme
- Los schemas de Pydantic son más expresivos y permiten validaciones complejas

#### ✅ Validación de Respuestas
- Podemos validar que los servicios devuelven datos en el formato correcto
- Útil para testing: podemos verificar que las respuestas cumplen el contrato
- Previene bugs donde un servicio devuelve datos incorrectos

#### ✅ Tipos Específicos
- Usamos `Decimal` para precios (no `float`) para evitar errores de precisión
- Pydantic valida que los valores sean Decimal válidos
- `Optional[Decimal]` permite None explícitamente cuando el precio base no existe

---

## 3. Schemas Reutilizables

### Ubicación: `app/schemas/common.py`

Este archivo demuestra otro beneficio clave de Pydantic: crear schemas reutilizables.

#### ✅ Consistencia en Toda la API
- Todas las respuestas exitosas siguen el mismo formato (`SuccessResponse`)
- Todos los errores siguen el mismo formato (`ErrorResponse`)
- La paginación siempre tiene la misma estructura (`PaginationInfo`)

#### ✅ DRY (Don't Repeat Yourself)
- En lugar de definir paginación en cada schema de respuesta, la definimos una vez
- `PaginatedResponse` puede usarse con cualquier tipo de dato (`List[Any]`)
- Si cambia la estructura de paginación, solo actualizamos aquí

#### ✅ Tipado Fuerte
- `SuccessResponse` siempre tiene `success=True` (hardcodeado)
- `ErrorResponse` siempre tiene `success=False`
- Esto previene errores donde accidentalmente devolvemos success incorrecto

---

## 4. Modelos de Dominio

### Ubicación: `app/models/`

### Diferencia entre Models y Schemas:

**SCHEMAS** (`app/schemas/`):
- Para validar datos de **ENTRADA y SALIDA** de la API
- Definen el contrato entre cliente y servidor
- Se usan en controladores para validar requests/responses

**MODELS** (`app/models/`):
- Para representar **ENTIDADES DEL DOMINIO**
- Representan datos que vienen de la base de datos
- Se usan en repositorios y servicios para trabajar con datos estructurados

### Beneficios de usar Pydantic para Models:

#### ✅ Conversión Automática desde Objetos ORM
- `Config.from_attributes = True` permite crear instancias desde objetos SQLAlchemy/ORM
- No necesitamos convertir manualmente cada campo
- Ejemplo: `Reserva.from_orm(db_object)` convierte automáticamente

#### ✅ Validación de Datos de Base de Datos
- Aunque confiamos en la BD, Pydantic valida tipos al cargar datos
- Detecta problemas temprano si hay inconsistencias en la BD
- Previene errores de tipo en tiempo de ejecución

#### ✅ Tipado Fuerte
- Los modelos definen claramente qué campos existen y sus tipos
- El IDE puede autocompletar y detectar errores
- Facilita el refactoring: cambios de estructura se detectan en tiempo de compilación

#### ✅ Serialización a JSON
- Pydantic convierte automáticamente a JSON cuando necesario
- Maneja correctamente datetime, Optional, Decimal, etc.
- Útil para logging, debugging, o APIs

#### ✅ Documentación del Dominio
- Los modelos documentan qué representa cada entidad
- Los comentarios explican el propósito de cada campo
- Facilita entender la estructura de datos del negocio

---

## 5. Configuración con pydantic-settings

### Ubicación: `app/config.py`

Usamos `pydantic_settings.BaseSettings` en lugar de cargar variables de entorno manualmente.

### Beneficios:

#### ✅ Carga Automática desde .env
- `BaseSettings` lee automáticamente el archivo `.env` (configurado en `Config.env_file`)
- No necesitamos llamar `load_dotenv()` manualmente
- Las variables se cargan al instanciar la clase

#### ✅ Validación de Tipos
- Pydantic valida que `DATABASE_PORT` sea un int (no string "3306")
- Convierte automáticamente tipos cuando es posible
- Si una variable requerida falta, lanza error claro al iniciar la app

**Ejemplo de error que previene:**
```python
# Sin Pydantic:
DATABASE_PORT = os.getenv("DATABASE_PORT", "3306")  # String "3306"
connection = connect(port=DATABASE_PORT)  # Error: espera int, recibe string

# Con Pydantic:
DATABASE_PORT: int = int(os.getenv("DATABASE_PORT", "3306"))  # Convierte a int
# O mejor aún, Pydantic lo hace automáticamente con anotación de tipo
```

#### ✅ Valores por Defecto
- Podemos definir valores por defecto directamente en la clase
- Si falta una variable de entorno, usa el valor por defecto
- Facilita desarrollo local sin necesidad de .env completo

#### ✅ Case Insensitive
- `Config.case_sensitive = False` permite usar `DATABASE_HOST` o `database_host`
- Más flexible y tolerante a errores de escritura

#### ✅ Propiedades Computadas
- `DATABASE_URL` es una propiedad que se calcula dinámicamente
- Pydantic permite propiedades y métodos además de campos
- Útil para valores derivados de otros campos

#### ✅ Validación al Inicio
- Si la configuración es inválida, la app falla al iniciar (fail-fast)
- Mejor que fallar en tiempo de ejecución cuando se usa la configuración
- Facilita detectar problemas de configuración en deployment

---

## 6. Uso en Controladores

### Ejemplo práctico: `app/controllers/reserva_controller.py`

```python
try:
    # VALIDACIÓN AUTOMÁTICA CON PYDANTIC:
    # ReservaCreate(**request.json) valida automáticamente que:
    # - id_funcion sea int y > 0
    # - id_butaca sea int y > 0
    # - dni sea string entre 7 y 11 caracteres
    # Si alguna validación falla, Pydantic lanza ValidationError con detalles claros
    data = ReservaCreate(**request.json)
    
    result = reserva_service.crear_reserva(
        id_funcion=data.id_funcion,
        id_butaca=data.id_butaca,
        dni=data.dni
    )
    return result, 201
    
except PydanticValidationError as e:
    # CAPTURAMOS ERRORES DE VALIDACIÓN DE PYDANTIC:
    # PydanticValidationError contiene información detallada sobre qué campos
    # son inválidos y por qué. Convertimos esto en respuesta HTTP 400 para
    # que el cliente sepa exactamente qué corregir.
    # Ejemplo de error que Pydantic genera:
    # "id_funcion: ensure this value is greater than 0"
    # "dni: ensure this value has at least 7 characters"
    ns.abort(400, message=f"Datos invalidos: {str(e)}")
```

---

## 7. Validación de Parámetros de Consulta

### Ubicación: `app/schemas/reporte.py`

Este archivo demuestra otro uso importante de Pydantic: validar parámetros de consulta.

En lugar de validar manualmente cada parámetro en el controlador, podríamos usar schemas para validar automáticamente:

**Ejemplo de mejora potencial:**
```python
params = ReporteOcupacionParams(
    id_pelicula=request.args.get('idPelicula'),
    fecha_inicio=request.args.get('fechaInicio'),
    fecha_fin=request.args.get('fechaFin')
)
```

Esto validaría automáticamente:
- `id_pelicula > 0`
- `fecha_inicio` y `fecha_fin` son fechas válidas
- Tipos correctos sin conversión manual

### Mapeo con Alias

`ReporteOcupacionItem` usa `alias` para mapear nombres de la base de datos (PascalCase) a nombres Python (snake_case). Esto es útil porque:
- La BD devuelve "IdFuncion", "TotalButacasVendidas"
- Python prefiere "id_funcion", "total_butacas_vendidas"
- `populate_by_name=True` permite usar ambos formatos

---

## 8. Organización de Schemas

### Ubicación: `app/schemas/__init__.py`

Este módulo centraliza todos los schemas de Pydantic para facilitar su importación.

### Beneficios:

#### ✅ Importaciones Simples
- En lugar de: `from app.schemas.reserva import ReservaCreate`
- Podemos usar: `from app.schemas import ReservaCreate`
- Más limpio y fácil de recordar

#### ✅ Visibilidad de Schemas Disponibles
- El `__all__` lista todos los schemas disponibles
- Los desarrolladores pueden ver qué schemas existen sin buscar en múltiples archivos
- Facilita descubrir schemas reutilizables

#### ✅ Refactoring Más Fácil
- Si movemos un schema a otro archivo, solo actualizamos este `__init__.py`
- Los imports en otros archivos siguen funcionando sin cambios
- Reduce el acoplamiento entre módulos

### Estructura:
- `common.py`: Schemas reutilizables (SuccessResponse, ErrorResponse, PaginationInfo)
- `precio.py`: Schemas relacionados con precios de funciones
- `reserva.py`: Schemas para operaciones de reservas
- `reporte.py`: Schemas para reportes de ocupación

Cada archivo contiene schemas específicos de su dominio, mientras que `common.py` contiene schemas genéricos usados en múltiples contextos.

---

## Resumen de Beneficios

### 🎯 Validación Automática
- No necesitamos escribir validaciones manuales repetitivas
- Los errores se detectan temprano con mensajes claros
- Previene bugs de tipo en producción

### 🔒 Seguridad
- Rechaza datos malformados antes de procesarlos
- Reduce la superficie de ataque
- Valida tipos y reglas de negocio automáticamente

### 📚 Documentación
- Genera documentación OpenAPI/Swagger automáticamente
- Los schemas documentan el contrato de la API
- Facilita la integración con frontend u otros servicios

### 🛠️ Mantenibilidad
- Centraliza definiciones de estructuras de datos
- Cambios en un solo lugar se propagan automáticamente
- Facilita el testing y refactoring

### 🚀 Productividad
- Menos código boilerplate
- Autocompletado en el IDE
- Detección de errores en tiempo de desarrollo

---

## Referencias

- [Documentación oficial de Pydantic](https://docs.pydantic.dev/)
- [Pydantic Settings](https://docs.pydantic.dev/latest/concepts/pydantic_settings/)
- [Validación de datos con Pydantic](https://docs.pydantic.dev/latest/concepts/validators/)

