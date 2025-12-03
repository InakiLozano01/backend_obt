"""
Controlador de Precios - Endpoints para calcular precios

Para más información sobre cómo y por qué usamos Pydantic en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from flask_restx import Namespace, Resource, fields
from app.services.precio_service import PrecioService
from app.utils.exceptions import AppException

ns = Namespace('precios', description='Operaciones de precios de funciones')

precio_response_model = ns.model('PrecioResponse', {
    'id_funcion': fields.Integer(required=True, description='ID de la funcion'),
    'precio_final': fields.Float(required=True, description='Precio final calculado'),
    'mensaje': fields.String(required=True, description='Mensaje del calculo')
})

error_model = ns.model('ErrorResponse', {
    'success': fields.Boolean(default=False),
    'message': fields.String(description='Mensaje de error'),
    'error': fields.String(description='Tipo de error')
})

precio_service = PrecioService()


# Decoradores (@) en flask-restx:
# Los decoradores como @ns.route, @ns.doc, @ns.marshal_with, @ns.response, etc. 
# se utilizan para agregar metadatos, definir rutas y manipular el comportamiento de los métodos en los recursos (clases)
# que exponen endpoints de la API REST.
# Por ejemplo:
# - @ns.route('/<int:id_funcion>') define la ruta URL para la cual la clase será el manejador.
# - @ns.response agrega documentación y modelos de respuesta para diferentes códigos HTTP.
# - @ns.doc agrega información de documentación Swagger.
# - @ns.marshal_with indica el esquema de datos a devolver en la respuesta.
# Los decoradores permiten que Flask y Flask-Restx automaticen la generación de rutas y documentación
# asociando metadatos y comportamientos extra a los métodos y clases.

@ns.route('/<int:id_funcion>')
@ns.param('id_funcion', 'ID de la funcion')
class PrecioResource(Resource):
    """Endpoint para obtener precio de una funcion"""
    
    @ns.doc('get_precio')
    @ns.marshal_with(precio_response_model)
    @ns.response(200, 'Precio calculado exitosamente')
    @ns.response(400, 'Funcion inactiva o finalizada', error_model)
    @ns.response(404, 'Funcion no encontrada', error_model)
    @ns.response(500, 'Error del servidor', error_model)
    def get(self, id_funcion):
        """
        Obtener precio calculado de una funcion
        
        Utiliza el SP SP_DeterminarPrecioEntrada para calcular el precio
        con recargos segun genero y tipo de sala.
        
        Reglas de precio:
        - Genero Estreno o 3D: +10%
        - Sala VIP (IdSala=1): +5%
        """
        try:
            result = precio_service.obtener_precio(id_funcion)
            return result, 200
            
        except AppException as e:
            ns.abort(e.status_code, message=e.message)
        except Exception as e:
            ns.abort(500, message=f"Error interno del servidor: {str(e)}")

