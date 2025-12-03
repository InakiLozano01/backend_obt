"""
Schemas Pydantic para validacion de request/response

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from app.schemas.common import ErrorResponse, SuccessResponse, PaginationInfo, PaginatedResponse
from app.schemas.precio import PrecioResponse
from app.schemas.reserva import ReservaCreate, ReservaResponse, ReservaDetalle, ReservaListResponse
from app.schemas.reporte import ReporteOcupacionParams, ReporteOcupacionItem, ReporteOcupacionResponse

__all__ = [
    # Common
    'ErrorResponse',
    'SuccessResponse',
    'PaginationInfo',
    'PaginatedResponse',
    # Precio
    'PrecioResponse',
    # Reserva
    'ReservaCreate',
    'ReservaResponse',
    'ReservaDetalle',
    'ReservaListResponse',
    # Reporte
    'ReporteOcupacionParams',
    'ReporteOcupacionItem',
    'ReporteOcupacionResponse'
]

