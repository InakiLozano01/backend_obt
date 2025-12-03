"""
Modelo de Reserva de butaca
Nos permite representar una reserva de butaca con sus atributos

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class Reserva(BaseModel):
    """Modelo de Reserva de butaca"""
    # Atributos de la reserva de butaca
    IdReserva: int
    IdFuncion: int
    IdPelicula: int
    IdSala: int
    IdButaca: int
    DNI: str
    FechaAlta: datetime
    FechaBaja: Optional[datetime] = None
    EstaPagada: str
    Observaciones: Optional[str] = None
    
    class Config:
        from_attributes = True


class ReservaDetalle(BaseModel):
    """Modelo de Reserva con detalles (para SP_ReservasPorDNI)"""
    # Atributos de la reserva con detalles
    IdReserva: int
    DNI: str
    IdFuncion: int
    FechaInicio: datetime
    Pelicula: str
    Sala: str
    EstaPagada: str
    FechaAlta: datetime
    FechaBaja: Optional[datetime] = None
    
    class Config:
        from_attributes = True

