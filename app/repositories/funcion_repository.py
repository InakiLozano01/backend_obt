"""
Repositorio para funciones de cine
Nos permite obtener el precio calculado de una funcion con recargos segun genero y tipo de sala
"""
from typing import Tuple, Optional
from decimal import Decimal
from app.database import call_sp_with_out_params


class FuncionRepository:
    """Repositorio para acceso a datos de funciones"""
    
    @staticmethod
    def get_precio_funcion(id_funcion: int) -> Tuple[Optional[Decimal], str]:
        """
        Obtener precio calculado de una funcion usando SP_DeterminarPrecioEntrada
        
        Args:
            id_funcion: ID de la funcion
        
        Returns:
            Tupla con (precio_final, mensaje)
        """
        # Obtenemos el precio calculado de una funcion usando el sp SP_DeterminarPrecioEntrada
        _, out_values = call_sp_with_out_params(
            'SP_DeterminarPrecioEntrada',
            in_params=(id_funcion,),
            out_param_count=2
        )
        
        # Desempaquetamos el resultado del stored procedure
        precio_final, mensaje = out_values
        if precio_final is not None:
            precio_final = Decimal(str(precio_final))
        
        # Devolvemos el precio calculado de la funcion
        return precio_final, mensaje or 'Error desconocido'

