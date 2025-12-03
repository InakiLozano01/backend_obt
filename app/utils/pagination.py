"""
Utilidad para paginacion de resultados de la aplicacion
Nos permite paginar los resultados de las consultas a la base de datos
De manera uniforme y facil de usar en todos los controladores
"""
from typing import List, Any, Dict
from math import ceil


def paginate(
    items: List[Any],
    page: int = 1,
    per_page: int = 10
) -> Dict[str, Any]:
    """
    Paginar una lista de items

    Esta funcion es la que usaremos en los servicios para paginar los resultados de las consultas a la base de datos
    Args:
        items: Lista de elementos a paginar
        page: Numero de pagina (1-indexed)
        per_page: Elementos por pagina
    
    Returns:
        Diccionario con datos paginados y metadata
    """
    # Si el numero de pagina es menor a 1, se establece a 1 como minimo (pagina 0 no existe)
    if page < 1:
        page = 1
    # Si el numero de elementos por pagina es menor a 1, se establece a 10 como minimo
    if per_page < 1:
        per_page = 10
    # Si el numero de elementos por pagina es mayor a 100, se establece a 100 como maximo
    if per_page > 100:
        per_page = 100
    
    # Calculamos el total de elementos y el numero de paginas
    total = len(items)
    total_pages = ceil(total / per_page) if total > 0 else 1
    
    # Si el numero de pagina es mayor al numero de paginas, se establece al numero de paginas como maximo
    if page > total_pages:
        page = total_pages
    
    # Calculamos el indice de inicio y fin de los elementos a paginar
    start_idx = (page - 1) * per_page
    end_idx = start_idx + per_page
    data = items[start_idx:end_idx]

    # Devolvemos los datos paginados y la metadata para el frontend
    return {
        'data': data,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': total,
            'total_pages': total_pages,
            'has_next': page < total_pages,
            'has_prev': page > 1
        }
    }

