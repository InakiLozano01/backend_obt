"""
Configuracion de la aplicacion Flask
Nos permite cargar las variables de entorno desde el archivo .env
Y asi, tener una configuracion centralizada y facil de mantener

Para más información sobre cómo y por qué usamos Pydantic (pydantic_settings) en este repositorio,
consulta el archivo PYDANTIC.md en la raíz del proyecto.
"""
from pydantic_settings import BaseSettings


class Config(BaseSettings):
    """Configuracion de la aplicacion"""
    
    # Flask
    FLASK_APP: str = "app.py"
    FLASK_ENV: str = "development"
    FLASK_DEBUG: bool = True
    FLASK_PORT: int = 5000
    SECRET_KEY: str = "dev-secret-key"
    
    # Base de datos
    DATABASE_HOST: str = "localhost"
    DATABASE_PORT: int = 3306
    DATABASE_NAME: str = "cine_db"
    DATABASE_USER: str = "app_user"
    DATABASE_PASSWORD: str = "app_password"
    
    # MySQL (variables para Docker Compose)
    MYSQL_ROOT_PASSWORD: str = "rootpassword"
    MYSQL_DATABASE: str = "cine_db"
    MYSQL_USER: str = "app_user"
    MYSQL_PASSWORD: str = "app_password"
    MYSQL_PORT: int = 3306
    
    # Control de inicialización (solo para Docker)
    INIT_ON_RESTART: str = "true"
    
    @property
    def DATABASE_URL(self) -> str:
        """URL de conexión a la base de datos"""
        return f"mysql+pymysql://{self.DATABASE_USER}:{self.DATABASE_PASSWORD}@{self.DATABASE_HOST}:{self.DATABASE_PORT}/{self.DATABASE_NAME}"
    
    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "ignore"  # Ignorar campos extra en .env que no están definidos en la clase

