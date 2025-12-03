"""
Controlador de Reportes - Endpoints para generar reportes
"""
from flask import request
from flask_restx import Namespace, Resource, fields
from datetime import datetime
from app.services.reporte_service import ReporteService
from app.utils.exceptions import AppException, ValidationError

ns = Namespace('reporte', description='Operaciones de reportes')

reporte_item_model = ns.model('ReporteOcupacionItem', {
    'IdFuncion': fields.Integer(description='ID de la funcion'),
    'FechaInicio': fields.DateTime(description='Fecha inicio de la funcion'),
    'IdSala': fields.Integer(description='ID de la sala'),
    'Sala': fields.String(description='Nombre de la sala'),
    'TotalButacasVendidas': fields.Integer(description='Total de butacas vendidas'),
    'TotalIngresosRecaudados': fields.Float(description='Total de ingresos recaudados')
})

pagination_model = ns.model('Pagination', {
    'page': fields.Integer(description='Pagina actual'),
    'per_page': fields.Integer(description='Elementos por pagina'),
    'total': fields.Integer(description='Total de elementos'),
    'total_pages': fields.Integer(description='Total de paginas'),
    'has_next': fields.Boolean(description='Hay pagina siguiente'),
    'has_prev': fields.Boolean(description='Hay pagina anterior')
})

reporte_response_model = ns.model('ReporteOcupacionResponse', {
    'data': fields.List(fields.Nested(reporte_item_model)),
    'pagination': fields.Nested(pagination_model)
})

error_model = ns.model('ErrorResponse', {
    'success': fields.Boolean(default=False),
    'message': fields.String(description='Mensaje de error'),
    'error': fields.String(description='Tipo de error')
})

reporte_service = ReporteService()

# Comentario sobre decoradores (@):
# En Flask y Flask-RESTx, los decoradores como @ns.route, @ns.param, @ns.doc, @ns.response y @ns.marshal_with
# se utilizan para agregar metadata, definir rutas, documentar o modificar el comportamiento de las funciones
# y clases que exponen endpoints de la API REST. Por ejemplo, @ns.route('/ocupacion') asigna la ruta URL que
# la clase va a manejar. Los decoradores permiten automatizar el ruteo, la validación y la documentación 
# Swagger/OpenAPI de los endpoints en Flask y Flask-RESTx.

@ns.route('/ocupacion')
class ReporteOcupacion(Resource):
    """Endpoint para reporte de ocupacion por pelicula"""
    
    @ns.doc('get_reporte_ocupacion')
    @ns.param('idPelicula', 'ID de la pelicula (requerido)', type=int, _in='query', required=True)
    @ns.param('fechaInicio', 'Fecha inicio del periodo (YYYY-MM-DD, requerido)', type=str, _in='query', required=True)
    @ns.param('fechaFin', 'Fecha fin del periodo (YYYY-MM-DD, requerido)', type=str, _in='query', required=True)
    @ns.param('page', 'Numero de pagina (default: 1)', type=int, _in='query')
    @ns.param('per_page', 'Elementos por pagina (default: 10, max: 100)', type=int, _in='query')
    @ns.marshal_with(reporte_response_model)
    @ns.response(200, 'Reporte generado exitosamente')
    @ns.response(400, 'Parametros invalidos', error_model)
    @ns.response(500, 'Error del servidor', error_model)
    def get(self):
        """
        Generar reporte de ocupacion por pelicula
        
        Utiliza el SP SP_ReporteOcupacionPorPelicula para generar el reporte.
        
        El reporte muestra para cada funcion:
        - Fecha y hora de inicio
        - Sala donde se proyecto
        - Total de butacas vendidas (reservas activas y pagadas)
        - Total de ingresos recaudados
        
        Soporta paginacion con los parametros page y per_page.
        """
        try:
            id_pelicula = request.args.get('idPelicula', type=int)
            fecha_inicio_str = request.args.get('fechaInicio')
            fecha_fin_str = request.args.get('fechaFin')
            
            if not id_pelicula:
                ns.abort(400, message="El parametro idPelicula es requerido")
            if not fecha_inicio_str:
                ns.abort(400, message="El parametro fechaInicio es requerido")
            if not fecha_fin_str:
                ns.abort(400, message="El parametro fechaFin es requerido")
            
            try:
                fecha_inicio = datetime.strptime(fecha_inicio_str, '%Y-%m-%d').date()
                fecha_fin = datetime.strptime(fecha_fin_str, '%Y-%m-%d').date()
            except ValueError:
                ns.abort(400, message="Formato de fecha invalido. Use YYYY-MM-DD")
            
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            
            result = reporte_service.generar_reporte_ocupacion(
                id_pelicula=id_pelicula,
                fecha_inicio=fecha_inicio,
                fecha_fin=fecha_fin,
                page=page,
                per_page=per_page
            )
            return result, 200
            
        except AppException as e:
            ns.abort(e.status_code, message=e.message)
        except Exception as e:
            ns.abort(500, message=f"Error interno del servidor: {str(e)}")

