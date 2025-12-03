"""
Schemas para endpoints de reportes

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel, Field
from typing import List
from datetime import datetime, date
from decimal import Decimal


# Schema para parametros del reporte de ocupacion por pelicula
class ReporteOcupacionParams(BaseModel):
    """Schema para parametros del reporte de ocupacion"""
    id_pelicula: int = Field(..., description="ID de la pelicula", gt=0)
    fecha_inicio: date = Field(..., description="Fecha de inicio del periodo")
    fecha_fin: date = Field(..., description="Fecha fin del periodo")
    
    class Config:
        json_schema_extra = {
            "example": {
                "id_pelicula": 1,
                "fecha_inicio": "2025-12-01",
                "fecha_fin": "2025-12-31"
            }
        }


# Schema para item del reporte de ocupacion por pelicula
class ReporteOcupacionItem(BaseModel):
    """Schema de item del reporte de ocupacion"""
    id_funcion: int = Field(..., alias="IdFuncion")
    fecha_inicio: datetime = Field(..., alias="FechaInicio")
    id_sala: int = Field(..., alias="IdSala")
    sala: str = Field(..., alias="Sala")
    total_butacas_vendidas: int = Field(..., alias="TotalButacasVendidas")
    total_ingresos_recaudados: Decimal = Field(..., alias="TotalIngresosRecaudados")
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "id_funcion": 1,
                "fecha_inicio": "2025-12-15T20:00:00",
                "id_sala": 1,
                "sala": "Sala VIP",
                "total_butacas_vendidas": 45,
                "total_ingresos_recaudados": 5175.00
            }
        }


# Schema para respuesta del reporte de ocupacion por pelicula
class ReporteOcupacionResponse(BaseModel):
    """Schema de respuesta para reporte de ocupacion"""
    data: List[ReporteOcupacionItem] = Field(..., description="Lista de funciones con ocupacion")
    pagination: dict = Field(..., description="Informacion de paginacion")
    
    class Config:
        json_schema_extra = {
            "example": {
                "data": [
                    {
                        "id_funcion": 1,
                        "fecha_inicio": "2025-12-15T20:00:00",
                        "id_sala": 1,
                        "sala": "Sala VIP",
                        "total_butacas_vendidas": 45,
                        "total_ingresos_recaudados": 5175.00
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

