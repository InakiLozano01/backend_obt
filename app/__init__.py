"""
Inicializacion de la aplicacion Flask con Flask-RESTX para Swagger
API de Sistema de Cine - Arquitectura Controller-Service-Repository
"""
from flask import Flask
from flask_restx import Api
from flask_cors import CORS
from app.config import Config
from app.database import init_db


def create_app(config_class=Config):
    """Factory function para crear la aplicacion Flask"""
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Habilitar CORS
    CORS(app)
    
    # Inicializar base de datos
    init_db()
    
    # Configurar API con Swagger
    api = Api(
        app,
        version='1.0',
        title='API Sistema de Cine',
        description='''
API RESTful para gestion de reservas de cine.

## Arquitectura
- **Controller**: Manejo de HTTP requests/responses
- **Service**: Logica de negocio
- **Repository**: Acceso a datos via Stored Procedures

## Endpoints
- **GET /precios/{idFuncion}**: Calcular precio de una funcion
- **GET /reporte/ocupacion**: Reporte de ocupacion por pelicula
- **POST /reservas**: Crear una reserva
- **GET /reservas/{dni}**: Listar reservas por DNI
        ''',
        doc='/swagger/',
        prefix='/api/v1'
    )
    
    # Registrar controladores
    from app.controllers import register_controllers
    register_controllers(api)
    
    return app

