"""
Modulo para manejo de conexiones a la base de datos y stored procedures
Nos permite conectar la aplicacion con MySQL y ejecutar stored procedures
Y asi, tener un acceso a la base de datos de manera uniforme y facil de usar en todos los controladores
"""
import pymysql
from contextlib import contextmanager
from typing import Dict, List, Any, Optional, Tuple
from app.config import Config

config = Config()


def get_db_connection():
    """Obtener una conexion a la base de datos"""
    return pymysql.connect(
        host=config.DATABASE_HOST,
        port=config.DATABASE_PORT,
        user=config.DATABASE_USER,
        password=config.DATABASE_PASSWORD,
        database=config.DATABASE_NAME,
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False
    )


@contextmanager
def get_db():
    """Context manager para manejar conexiones a la base de datos con manejo de errores y commits/rollbacks"""
    conn = None
    try:
        conn = get_db_connection()
        yield conn  # Yield es como un return, pero para context managers
        # Si todo va bien, commiteamos la transaccion
        conn.commit()
    except Exception as e:
        if conn:
            # Si hay un error, rollbackamos la transaccion
            conn.rollback()
        raise e
    finally:
        if conn:
            conn.close()

# Esta función es la que usaremos en el inicio de la aplicación para verificar la conectividad con la base de datos
def init_db():
    """Inicializar la conexión a la base de datos (verificar conectividad)"""
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT 1")
                print("Conexion a la base de datos establecida correctamente")
    except Exception as e:
        print(f"Error al conectar con la base de datos: {e}")
        raise

# Esta función es la que usaremos en los servicios para ejecutar stored procedures
def call_stored_procedure(
    procedure_name: str,
    params: Optional[Tuple] = None,
    fetch: bool = True
) -> Optional[List[Dict[str, Any]]]:
    """
    Ejecutar un stored procedure con manejo de errores y commits/rollbacks
    
    Args:
        procedure_name: Nombre del stored procedure
        params: Tupla con los parametros del stored procedure
        fetch: Si True, retorna los resultados. Si False, solo ejecuta.
    
    Returns:
        Lista de diccionarios con los resultados o None si fetch=False
    
    Raises:
        Exception: Si hay un error al ejecutar el stored procedure
    """
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                if params:
                    cursor.callproc(procedure_name, params)
                else:
                    cursor.callproc(procedure_name)
                if fetch:
                    # pymysql: usar fetchall() directamente despues de callproc
                    results = cursor.fetchall()
                    # Si hay multiples result sets, iterar con nextset()
                    all_results = [results] if results else []
                    while cursor.nextset():
                        more_results = cursor.fetchall()
                        if more_results:
                            all_results.append(more_results)
                    # Retornar el primer result set (comportamiento mas comun)
                    return all_results[0] if all_results else None
                else:
                    return None
    except Exception as e:
        raise

# Esta función es la que usaremos en los repositorios para ejecutar funciones de MySQL
def call_function(
    function_name: str,
    params: Optional[Tuple] = None
) -> Any:
    """
    Ejecutar una función de MySQL con manejo de errores y commits/rollbacks

    Args:
        function_name: Nombre de la función
        params: Tupla con los parametros de la funcion

    Returns:
        Resultado de la función

    Raises:
        Exception: Si hay un error al ejecutar la función
    """
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                if params:
                    placeholders = ','.join(['%s'] * len(params))
                    query = f"SELECT {function_name}({placeholders}) AS result"
                    cursor.execute(query, params)
                else:
                    query = f"SELECT {function_name}() AS result"
                    cursor.execute(query)
                result = cursor.fetchone()
                return result['result'] if result else None
    except Exception as e:
        raise

# Esta función es la que usaremos en los repositorios para ejecutar consultas SQL personalizadas
def execute_query(
    query: str,
    params: Optional[Tuple] = None,
    fetch: bool = True,
    fetch_one: bool = False
) -> Optional[List[Dict[str, Any]]]:
    """
    Ejecutar una consulta SQL personalizada con manejo de errores y commits/rollbacks
    
    Args:
        query: Consulta SQL
        params: Tupla con los parametros de la consulta
        fetch: Si True, retorna los resultados
        fetch_one: Si True, retorna solo el primer resultado

    Raises:
        Exception: Si hay un error al ejecutar la consulta
    Returns:
        Resultados de la consulta
    """
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                if fetch:
                    results = cursor.fetchall()
                    return results if results else None
                elif fetch_one:
                    result = cursor.fetchone()
                    return result if result else None
                else:
                    return None
    except Exception as e:
        raise

# Esta función es la que usaremos en los repositorios para ejecutar stored procedures con parámetros OUT (salida de datos)
def call_sp_with_out_params(
    procedure_name: str,
    in_params: Tuple,
    out_param_count: int
) -> Tuple[Optional[List[Dict[str, Any]]], Tuple]:
    """
    Ejecutar un stored procedure con parametros OUT (salida de datos) con manejo de errores y commits/rollbacks
    
    Args:
        procedure_name: Nombre del stored procedure
        in_params: Tupla con los parametros IN del stored procedure
        out_param_count: Numero de parametros OUT

    Returns:
        Tupla con (resultados del SELECT si hay, tupla de valores OUT)

    Raises:
        Exception: Si hay un error al ejecutar el stored procedure

    Ejemplo:
        # SP_DeterminarPrecioEntrada tiene 1 IN (idFuncion) y 2 OUT (precio, mensaje)
        results, out_values = call_sp_with_out_params(
            'SP_DeterminarPrecioEntrada',
            in_params=(1,),
            out_param_count=2
        )
        precio_final, mensaje = out_values
    """
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                all_params = list(in_params) + [None] * out_param_count
                cursor.callproc(procedure_name, all_params)
                results = cursor.fetchall()

                out_param_names = [
                    f"@_{procedure_name}_{i}" 
                    for i in range(len(in_params), len(in_params) + out_param_count)
                ]

                if out_param_names:
                    cursor.execute(f"SELECT {', '.join(out_param_names)}")
                    out_result = cursor.fetchone()
                    out_values = tuple(out_result.values()) if out_result else tuple([None] * out_param_count)
                else:
                    out_values = ()

                return results if results else None, out_values
    except Exception as e:
        raise
