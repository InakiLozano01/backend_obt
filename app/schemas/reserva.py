"""
Schemas para endpoints de reservas

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class ReservaCreate(BaseModel):
    """Schema para crear una reserva"""
    id_funcion: int = Field(..., description="ID de la funcion", gt=0)
    id_butaca: int = Field(..., description="ID de la butaca", gt=0)
    dni: str = Field(..., description="DNI del cliente", min_length=7, max_length=11)
    
    class Config:
        json_schema_extra = {
            "example": {
                "id_funcion": 1,
                "id_butaca": 5,
                "dni": "12345678"
            }
        }


class ReservaResponse(BaseModel):
    """Schema de respuesta para creacion de reserva"""
    success: bool = Field(..., description="Indica si la reserva fue exitosa")
    mensaje: str = Field(..., description="Mensaje de resultado")
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "mensaje": "Reserva creada exitosamente"
            }
        }


class ReservaDetalle(BaseModel):
    """Schema de detalle de reserva"""
    id_reserva: int = Field(..., alias="IdReserva")
    dni: str = Field(..., alias="DNI")
    id_funcion: int = Field(..., alias="IdFuncion")
    fecha_inicio: datetime = Field(..., alias="FechaInicio")
    pelicula: str = Field(..., alias="Pelicula")
    sala: str = Field(..., alias="Sala")
    esta_pagada: str = Field(..., alias="EstaPagada")
    fecha_alta: datetime = Field(..., alias="FechaAlta")
    fecha_baja: Optional[datetime] = Field(None, alias="FechaBaja")
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "id_reserva": 1,
                "dni": "12345678",
                "id_funcion": 1,
                "fecha_inicio": "2025-12-15T20:00:00",
                "pelicula": "Avatar 3",
                "sala": "Sala VIP",
                "esta_pagada": "S",
                "fecha_alta": "2025-12-01T10:30:00",
                "fecha_baja": None
            }
        }


class ReservaListResponse(BaseModel):
    """Schema de respuesta para lista de reservas"""
    data: List[ReservaDetalle] = Field(..., description="Lista de reservas")
    pagination: dict = Field(..., description="Informacion de paginacion")
    
    class Config:
        json_schema_extra = {
            "example": {
                "data": [
                    {
                        "id_reserva": 1,
                        "dni": "12345678",
                        "id_funcion": 1,
                        "fecha_inicio": "2025-12-15T20:00:00",
                        "pelicula": "Avatar 3",
                        "sala": "Sala VIP",
                        "esta_pagada": "S",
                        "fecha_alta": "2025-12-01T10:30:00",
                        "fecha_baja": None
                    }
                ],
                "pagination": {
                    "page": 1,
                    "per_page": 10,
                    "total": 1,
                    "total_pages": 1,
                    "has_next": False,
                    "has_prev": False
                }
            }
        }

