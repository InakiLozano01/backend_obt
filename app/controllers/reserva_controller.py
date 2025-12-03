"""
Controlador de Reservas - Endpoints para crear y listar reservas
"""
from flask import request
from flask_restx import Namespace, Resource, fields
from app.services.reserva_service import ReservaService
from app.schemas.reserva import ReservaCreate
from app.utils.exceptions import AppException, ValidationError
from pydantic import ValidationError as PydanticValidationError


ns = Namespace('reservas', description='Operaciones de reservas')

reserva_create_model = ns.model('ReservaCreate', {
    'id_funcion': fields.Integer(required=True, description='ID de la funcion'),
    'id_butaca': fields.Integer(required=True, description='ID de la butaca'),
    'dni': fields.String(required=True, description='DNI del cliente (7-11 caracteres)')
})

reserva_response_model = ns.model('ReservaResponse', {
    'success': fields.Boolean(required=True, description='Indica si fue exitoso'),
    'mensaje': fields.String(required=True, description='Mensaje de resultado')
})

reserva_detalle_model = ns.model('ReservaDetalle', {
    'IdReserva': fields.Integer(description='ID de la reserva'),
    'DNI': fields.String(description='DNI del cliente'),
    'IdFuncion': fields.Integer(description='ID de la funcion'),
    'FechaInicio': fields.DateTime(description='Fecha inicio de la funcion'),
    'Pelicula': fields.String(description='Nombre de la pelicula'),
    'Sala': fields.String(description='Nombre de la sala'),
    'EstaPagada': fields.String(description='Estado de pago (S/N)'),
    'FechaAlta': fields.DateTime(description='Fecha de creacion'),
    'FechaBaja': fields.DateTime(description='Fecha de baja')
})

pagination_model = ns.model('Pagination', {
    'page': fields.Integer(description='Pagina actual'),
    'per_page': fields.Integer(description='Elementos por pagina'),
    'total': fields.Integer(description='Total de elementos'),
    'total_pages': fields.Integer(description='Total de paginas'),
    'has_next': fields.Boolean(description='Hay pagina siguiente'),
    'has_prev': fields.Boolean(description='Hay pagina anterior')
})

reserva_list_model = ns.model('ReservaListResponse', {
    'data': fields.List(fields.Nested(reserva_detalle_model)),
    'pagination': fields.Nested(pagination_model)
})

error_model = ns.model('ErrorResponse', {
    'success': fields.Boolean(default=False),
    'message': fields.String(description='Mensaje de error'),
    'error': fields.String(description='Tipo de error')
})

reserva_service = ReservaService()

# Comentario sobre decoradores (@) en Flask y Flask-Restx:
# Los decoradores en Flask (por ejemplo @app.route o @ns.route, @ns.doc, @ns.marshal_with, etc.) se utilizan para asociar
# funciones o clases a rutas HTTP específicas, agregar documentación o definir metadatos y modelos de respuesta.
# Así, los decoradores permiten mapear endpoints, documentar parámetros o salidas y personalizar el comportamiento de los controladores.
# Ejemplo:
# - @ns.route('/<string:dni>') asocia la clase/método al endpoint HTTP GET o POST correspondiente.
# - @ns.marshal_with(schema) especifica el modelo de salida/documentación.
# - @ns.response documenta posibles respuestas HTTP y sus modelos.
# Esto facilita el ruteo y la generación automática de documentación Swagger/OpenAPI en APIs REST con Flask.

@ns.route('')
class ReservaList(Resource):
    """Endpoint para crear reservas"""
    
    @ns.doc('create_reserva')
    @ns.expect(reserva_create_model)
    @ns.marshal_with(reserva_response_model, code=201)
    @ns.response(201, 'Reserva creada exitosamente')
    @ns.response(400, 'Datos invalidos o funcion inactiva', error_model)
    @ns.response(404, 'Funcion o butaca no encontrada', error_model)
    @ns.response(409, 'Conflicto - butaca ocupada o limite DNI excedido', error_model)
    @ns.response(500, 'Error del servidor', error_model)
    def post(self):
        """
        Crear una nueva reserva
        
        Utiliza el SP SP_ReservarButacaConValidacionDNI para crear la reserva.
        
        Validaciones:
        - Funcion debe existir y estar activa
        - Butaca debe existir y pertenecer a la sala de la funcion
        - Butaca no debe estar ya reservada para esa funcion
        - DNI no puede tener mas de 4 reservas activas y pagadas en la misma fecha
        """
        try:
            # Validación automática con Pydantic - ver PYDANTIC.md para más detalles
            data = ReservaCreate(**request.json)
            
            result = reserva_service.crear_reserva(
                id_funcion=data.id_funcion,
                id_butaca=data.id_butaca,
                dni=data.dni
            )
            return result, 201
            
        except PydanticValidationError as e:
            # Error de validación de Pydantic - ver PYDANTIC.md para más detalles
            ns.abort(400, message=f"Datos invalidos: {str(e)}")
        except AppException as e:
            ns.abort(e.status_code, message=e.message)
        except Exception as e:
            ns.abort(500, message=f"Error interno del servidor: {str(e)}")


@ns.route('/<string:dni>')
@ns.param('dni', 'DNI del cliente')
class ReservaPorDNI(Resource):
    """Endpoint para listar reservas por DNI"""
    
    @ns.doc('get_reservas_por_dni')
    @ns.param('page', 'Numero de pagina (default: 1)', type=int, _in='query')
    @ns.param('per_page', 'Elementos por pagina (default: 10, max: 100)', type=int, _in='query')
    @ns.marshal_with(reserva_list_model)
    @ns.response(200, 'Lista de reservas obtenida')
    @ns.response(500, 'Error del servidor', error_model)
    def get(self, dni):
        """
        Obtener reservas de un cliente por DNI
        
        Utiliza el SP SP_ReservasPorDNI para obtener las reservas.
        Soporta paginacion con los parametros page y per_page.
        """
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            
            result = reserva_service.listar_reservas_por_dni(dni, page, per_page)
            return result, 200
            
        except AppException as e:
            ns.abort(e.status_code, message=e.message)
        except Exception as e:
            ns.abort(500, message=f"Error interno del servidor: {str(e)}")

