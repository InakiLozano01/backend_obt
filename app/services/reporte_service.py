"""
Servicio de Reportes - Logica de negocio para reportes
Nos permite generar reportes de ocupacion por pelicula
"""
from typing import Dict, Any
from datetime import date
from app.repositories.reporte_repository import ReporteRepository
from app.utils.pagination import paginate


class ReporteService:
    """Servicio para logica de negocio de reportes"""
    
    # Inicializamos el repositorio de reportes
    def __init__(self):
        self.reporte_repository = ReporteRepository()
    
    # Generamos un reporte de ocupacion por pelicula usando el repositorio de reportes
    def generar_reporte_ocupacion(
        self,
        id_pelicula: int,
        fecha_inicio: date,
        fecha_fin: date,
        page: int = 1,
        per_page: int = 10
    ) -> Dict[str, Any]:
        """
        Generar reporte de ocupacion por pelicula
        
        Args:
            id_pelicula: ID de la pelicula
            fecha_inicio: Fecha de inicio del periodo
            fecha_fin: Fecha fin del periodo
            page: Numero de pagina
            per_page: Elementos por pagina
        
        Returns:
            Diccionario con datos paginados del reporte
        """
        # Si la fecha de inicio es mayor a la fecha fin, se lanza una excepcion de validacion
        if fecha_inicio > fecha_fin:
            from app.utils.exceptions import ValidationError
            raise ValidationError("La fecha de inicio no puede ser mayor a la fecha fin")
        
        # Obtenemos los datos del reporte de ocupacion por pelicula usando el sp SP_ReporteOcupacionPorPelicula
        datos = self.reporte_repository.get_ocupacion_por_pelicula(id_pelicula, fecha_inicio, fecha_fin)
        return paginate(datos, page, per_page)

