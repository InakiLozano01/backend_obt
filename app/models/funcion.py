"""
Modelo de Funcion de cine
Nos permite representar una funcion de cine con sus atributos

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal


class Funcion(BaseModel):
    """Modelo de Funcion de cine"""
    # Atributos de la funcion
    IdFuncion: int
    IdPelicula: int
    IdSala: int
    FechaProbableInicio: datetime
    FechaProbableFin: datetime
    FechaInicio: datetime
    FechaFin: Optional[datetime] = None
    Precio: Decimal
    Estado: str
    Observaciones: Optional[str] = None
    
    class Config:
        from_attributes = True

