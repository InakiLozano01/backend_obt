"""
Excepciones personalizadas y mapeo de errores de la aplicacion
Definimos las excepciones que usaremos en la aplicacion para manejar errores de manera uniforme
"""
from typing import Optional


class AppException(Exception):
    """Excepcion base de la aplicacion"""
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class NotFoundError(AppException):
    """Recurso no encontrado (404)"""
    def __init__(self, message: str = "Recurso no encontrado"):
        super().__init__(message, status_code=404)


class ConflictError(AppException):
    """Conflicto con el estado actual (409)"""
    def __init__(self, message: str = "Conflicto con el estado actual"):
        super().__init__(message, status_code=409)


class ValidationError(AppException):
    """Error de validacion (400)"""
    def __init__(self, message: str = "Datos invalidos"):
        super().__init__(message, status_code=400)


class InactiveResourceError(AppException):
    def __init__(self, message: str = "Recurso inactivo o finalizado"):
        super().__init__(message, status_code=400)

"""
Mapeo de mensajes de stored procedures a excepciones de la aplicacion
Esto nos permite manejar los errores de manera uniforme y evitar repetir codigo de manejo de errores en cada controlador
Asi, tenemos un 1 a 1 entre mensajes de stored procedures y excepciones de la aplicacion
"""

SP_ERROR_MAPPINGS = {
    'Funcion no encontrada': NotFoundError,
    'Funcion inactiva o finalizada': InactiveResourceError,
    'Butaca inexistente en la sala de la funcion': NotFoundError,
    'Butaca ya reservada para esta funcion': ConflictError,
    'Limite de 4 reservas activas y pagadas por fecha superado para este DNI': ConflictError,
}


def map_sp_message_to_exception(mensaje: str) -> Optional[AppException]:
    """
    Mapear mensaje de stored procedure a excepcion apropiada

    Si el mensaje es 'OK' o None, no se lanza ninguna excepcion
    Si el mensaje coincide con un patron de la lista SP_ERROR_MAPPINGS, se lanza la excepcion correspondiente
    Si no coincide con ningun patron, se lanza una excepcion AppException con el mensaje original
    Args:
        mensaje: Mensaje retornado por el stored procedure
    
    Returns:
        Excepcion correspondiente o None si es OK
    """
    if mensaje == 'OK' or mensaje is None:
        return None
    
    for pattern, exception_class in SP_ERROR_MAPPINGS.items():
        if pattern.lower() in mensaje.lower():
            return exception_class(mensaje)
    
    return AppException(mensaje, status_code=500)

