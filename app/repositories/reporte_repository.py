"""
Repositorio para reportes
Nos permite obtener el reporte de ocupacion por pelicula
"""
from typing import List, Dict, Any
from datetime import date
from app.database import call_stored_procedure


class ReporteRepository:
    """Repositorio para acceso a datos de reportes"""
    
    @staticmethod
    def get_ocupacion_por_pelicula(
        id_pelicula: int,
        fecha_inicio: date,
        fecha_fin: date
    ) -> List[Dict[str, Any]]:
        """
        Obtener reporte de ocupacion por pelicula usando SP_ReporteOcupacionPorPelicula
        
        Args:
            id_pelicula: ID de la pelicula
            fecha_inicio: Fecha de inicio del periodo
            fecha_fin: Fecha fin del periodo
        
        Returns:
            Lista de registros de ocupacion
        """
        # Obtenemos el reporte de ocupacion por pelicula usando el sp SP_ReporteOcupacionPorPelicula
        results = call_stored_procedure(
            'SP_ReporteOcupacionPorPelicula',
            params=(id_pelicula, fecha_inicio, fecha_fin)
        )
        # Devolvemos el reporte de ocupacion por pelicula
        return results or []

