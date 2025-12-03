"""
Configuracion de la aplicacion Flask
Nos permite cargar las variables de entorno desde el archivo .env
Y asi, tener una configuracion centralizada y facil de mantener

Para más información sobre cómo y por qué usamos Pydantic (pydantic_settings) en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
import os
from pydantic_settings import BaseSettings


class Config(BaseSettings):
    """Configuracion de la aplicacion"""
    
    # Flask
    FLASK_APP: str = "app.py"
    FLASK_ENV: str = "development"
    FLASK_DEBUG: bool = True
    FLASK_PORT: int = int(os.getenv("FLASK_PORT", "5000"))
    SECRET_KEY: str = os.getenv("SECRET_KEY", "dev-secret-key")
    
    # Base de datos
    DATABASE_HOST: str = os.getenv("DATABASE_HOST", "localhost")
    DATABASE_PORT: int = int(os.getenv("DATABASE_PORT", "3306"))
    DATABASE_NAME: str = os.getenv("DATABASE_NAME", "cine_db")
    DATABASE_USER: str = os.getenv("DATABASE_USER", "app_user")
    DATABASE_PASSWORD: str = os.getenv("DATABASE_PASSWORD", "app_password")
    
    # MySQL (variables para Docker Compose)
    MYSQL_ROOT_PASSWORD: str = os.getenv("MYSQL_ROOT_PASSWORD", "rootpassword")
    MYSQL_DATABASE: str = os.getenv("MYSQL_DATABASE", "cine_db")
    MYSQL_USER: str = os.getenv("MYSQL_USER", "app_user")
    MYSQL_PASSWORD: str = os.getenv("MYSQL_PASSWORD", "app_password")
    MYSQL_PORT: int = int(os.getenv("MYSQL_PORT", "3306"))
    
    # Control de inicialización (solo para Docker)
    INIT_ON_RESTART: str = os.getenv("INIT_ON_RESTART", "true")
    
    @property
    def DATABASE_URL(self) -> str:
        """URL de conexión a la base de datos"""
        return f"mysql+pymysql://{self.DATABASE_USER}:{self.DATABASE_PASSWORD}@{self.DATABASE_HOST}:{self.DATABASE_PORT}/{self.DATABASE_NAME}"
    
    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "ignore"  # Ignorar campos extra en .env que no están definidos en la clase

