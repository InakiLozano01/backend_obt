"""
Schemas para endpoints de precios

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel, Field
from decimal import Decimal
from typing import Optional


class PrecioResponse(BaseModel):
    """Schema de respuesta para precio de funcion"""
    id_funcion: int = Field(..., description="ID de la funcion")
    precio_base: Optional[Decimal] = Field(None, description="Precio base de la funcion")
    precio_final: Decimal = Field(..., description="Precio final calculado con recargos")
    mensaje: str = Field(..., description="Mensaje del calculo")
    
    class Config:
        json_schema_extra = {
            "example": {
                "id_funcion": 1,
                "precio_base": 100.00,
                "precio_final": 115.50,
                "mensaje": "OK"
            }
        }

