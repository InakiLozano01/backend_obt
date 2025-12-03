"""
Repositorio para reservas
Nos permite crear, listar y cancelar reservas
"""
from typing import List, Dict, Any, Tuple, Optional
from app.database import call_sp_with_out_params, call_stored_procedure


class ReservaRepository:
    """Repositorio para acceso a datos de reservas"""
    
    @staticmethod
    def crear_reserva(id_funcion: int, id_butaca: int, dni: str) -> str:
        """
        Crear una reserva usando SP_ReservarButacaConValidacionDNI
        
        Args:
            id_funcion: ID de la funcion
            id_butaca: ID de la butaca
            dni: DNI del cliente
        
        Returns:
            Mensaje del stored procedure (OK o error)
        """
        # Creamos una nueva reserva usando el sp SP_ReservarButacaConValidacionDNI
        _, out_values = call_sp_with_out_params(
            'SP_ReservarButacaConValidacionDNI',
            in_params=(id_funcion, id_butaca, dni),
            out_param_count=1
        )
        # Desempaquetamos el resultado del stored procedure
        mensaje = out_values[0] if out_values else 'Error desconocido'
        # Devolvemos el mensaje de la reserva
        return mensaje or 'Error desconocido'
    
    @staticmethod
    def get_reservas_por_dni(dni: str) -> List[Dict[str, Any]]:
        """
        Obtener reservas de un cliente usando SP_ReservasPorDNI
        
        Args:
            dni: DNI del cliente
        
        Returns:
            Lista de reservas con detalles
        """
        # Obtenemos las reservas de un cliente usando el sp SP_ReservasPorDNI
        results = call_stored_procedure(
            'SP_ReservasPorDNI',
            params=(dni,)
        )
        # Devolvemos las reservas de un cliente
        return results or []

