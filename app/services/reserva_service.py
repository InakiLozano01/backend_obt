"""
Servicio de Reservas - Logica de negocio para reservas
Nos permite crear, listar y cancelar reservas
"""
from typing import Dict, Any, List
from app.repositories.reserva_repository import ReservaRepository
from app.utils.exceptions import map_sp_message_to_exception
from app.utils.pagination import paginate


class ReservaService:
    """Servicio para logica de negocio de reservas"""
    
    # Inicializamos el repositorio de reservas
    def __init__(self):
        self.reserva_repository = ReservaRepository()
    
    # Creamos una nueva reserva usando el repositorio de reservas
    def crear_reserva(self, id_funcion: int, id_butaca: int, dni: str) -> Dict[str, Any]:
        """
        Crear una nueva reserva
        
        Args:
            id_funcion: ID de la funcion
            id_butaca: ID de la butaca
            dni: DNI del cliente
        
        Returns:
            Diccionario con success y mensaje
        
        Raises:
            NotFoundError: Si la funcion o butaca no existe
            ConflictError: Si la butaca ya esta reservada o limite de DNI excedido
            AppException: Otros errores
        """
        # Creamos una nueva reserva usando el sp SP_ReservarButacaConValidacionDNI
        mensaje = self.reserva_repository.crear_reserva(id_funcion, id_butaca, dni)

        # Mapeamos el mensaje de la reserva a una excepcion de la aplicacion
        # Si el mensaje es 'OK' o None, no se lanza ninguna excepcion
        exception = map_sp_message_to_exception(mensaje)
        if exception:
            raise exception
        
        # Devolvemos el resultado de la creacion de la reserva
        return {
            'success': True,
            'mensaje': 'Reserva creada exitosamente'
        }
    
    # Listamos las reservas de un cliente por DNI usando el repositorio de reservas
    def listar_reservas_por_dni(
        self, 
        dni: str, 
        page: int = 1, 
        per_page: int = 10
    ) -> Dict[str, Any]:
        """
        Listar reservas de un cliente por DNI
        
        Args:
            dni: DNI del cliente
            page: Numero de pagina
            per_page: Elementos por pagina
        
        Returns:
            Diccionario con datos paginados
        """
        # Obtenemos las reservas de un cliente por DNI usando el sp SP_ReservasPorDNI
        reservas = self.reserva_repository.get_reservas_por_dni(dni)
        return paginate(reservas, page, per_page)

