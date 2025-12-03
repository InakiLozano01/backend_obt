"""
Punto de entrada principal de la aplicación Flask
"""
import os
from dotenv import load_dotenv
from app import create_app
from app.config import Config

# Nos permite cargar las variables de entorno desde el archivo .env
load_dotenv()

# Asi creamos la aplicacion FLASK que usaremos en el resto de la app
app = create_app(Config)

if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', 5000)) #Fallback value por si no se encuentra la variable de entorno FLASK_PORT
    debug = os.getenv('FLASK_DEBUG', '1') == '1' #Fallback value por si no se encuentra la variable de entorno FLASK_DEBUG
    app.run(host='0.0.0.0', port=port, debug=debug) #Ejecutamos la aplicacion FLASK en el puerto y host especificados

