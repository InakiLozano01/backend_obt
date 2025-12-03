"""
Schemas comunes para respuestas de la API
Nos permite mantener un formato consistente para las respuestas de la API

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic import BaseModel, Field
from typing import Optional, Any, List


class SuccessResponse(BaseModel):
    """Schema para respuesta exitosa"""
    success: bool = True
    message: str
    data: Optional[Any] = None


class ErrorResponse(BaseModel):
    """Schema para respuesta de error"""
    success: bool = False
    message: str
    error: Optional[str] = None
    details: Optional[Any] = None


class PaginationInfo(BaseModel):
    """Schema para informacion de paginacion"""
    page: int = Field(..., description="Pagina actual")
    per_page: int = Field(..., description="Elementos por pagina")
    total: int = Field(..., description="Total de elementos")
    total_pages: int = Field(..., description="Total de paginas")
    has_next: bool = Field(..., description="Hay pagina siguiente")
    has_prev: bool = Field(..., description="Hay pagina anterior")


class PaginatedResponse(BaseModel):
    """Schema generico para respuestas paginadas"""
    data: List[Any] = Field(..., description="Lista de datos")
    pagination: PaginationInfo = Field(..., description="Informacion de paginacion")
