"""
Servicio de Precios - Logica de negocio para calcular precios
Nos permite calcular el precio de una funcion con recargos segun genero y tipo de sala
"""
from decimal import Decimal
from typing import Dict, Any
from app.repositories.funcion_repository import FuncionRepository
from app.utils.exceptions import map_sp_message_to_exception


class PrecioService:
    """Servicio para logica de negocio de precios"""
    
    # Inicializamos el repositorio de funciones
    def __init__(self):
        self.funcion_repository = FuncionRepository()
    
    # Obtenemos el precio calculado de una funcion usando el repositorio de funciones
    def obtener_precio(self, id_funcion: int) -> Dict[str, Any]:
        """
        Obtener precio calculado de una funcion
        
        Args:
            id_funcion: ID de la funcion
        
        Returns:
            Diccionario con precio_final y mensaje
        
        Raises:
            NotFoundError: Si la funcion no existe
            InactiveResourceError: Si la funcion esta inactiva o finalizada
            AppException: Otros errores
        """
        # Obtenemos el precio calculado de una funcion usando el sp SP_DeterminarPrecioEntrada
        precio_final, mensaje = self.funcion_repository.get_precio_funcion(id_funcion)

        # Mapeamos el mensaje de la funcion a una excepcion de la aplicacion
        # Si el mensaje es 'OK' o None, no se lanza ninguna excepcion
        exception = map_sp_message_to_exception(mensaje)
        if exception:
            raise exception
        
        # Devolvemos el precio calculado de la funcion
        return {
            'id_funcion': id_funcion,
            'precio_final': precio_final,
            'mensaje': mensaje
        }

