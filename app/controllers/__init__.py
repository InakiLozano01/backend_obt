"""
Capa de Controladores - Manejo de HTTP requests/responses
Capa que maneja las peticiones HTTP y las convierte en llamadas a los servicios
Segun arquitectura Controller-Service-Repository
"""
from app.controllers.precio_controller import ns as precio_ns
from app.controllers.reserva_controller import ns as reserva_ns
from app.controllers.reporte_controller import ns as reporte_ns


def register_controllers(api):
    """Registrar todos los namespaces de controladores como rutas de la API"""
    api.add_namespace(precio_ns, path='/precios')
    api.add_namespace(reserva_ns, path='/reservas')
    api.add_namespace(reporte_ns, path='/reporte')

