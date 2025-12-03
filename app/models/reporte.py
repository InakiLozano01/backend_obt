"""
Modelo de Reporte de Ocupacion
Nos permite representar un reporte de ocupacion por pelicula con sus atributos

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel
from datetime import datetime
from decimal import Decimal


class ReporteOcupacion(BaseModel):
    """Modelo de reporte de ocupacion por pelicula"""
    # Atributos del reporte de ocupacion por pelicula
    IdFuncion: int
    FechaInicio: datetime
    IdSala: int
    Sala: str
    TotalButacasVendidas: int
    TotalIngresosRecaudados: Decimal
    
    class Config:
        from_attributes = True

