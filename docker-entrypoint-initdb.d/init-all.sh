#!/bin/bash
# Script que se ejecuta automáticamente en /docker-entrypoint-initdb.d/
# MySQL ejecuta estos scripts SOLO en la primera inicialización

set -e

echo "=========================================="
echo "Inicializando base de datos cine_db"
echo "=========================================="

# Ejecutar init_db.sql
if [ -f /docker-entrypoint-initdb.d/init_db.sql ]; then
    echo "Ejecutando init_db.sql..."
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/init_db.sql
    echo "✓ init_db.sql ejecutado exitosamente."
else
    echo "✗ ERROR: init_db.sql no encontrado"
    exit 1
fi

# Ejecutar seed_db.sql
if [ -f /docker-entrypoint-initdb.d/seed_db.sql ]; then
    echo "Ejecutando seed_db.sql..."
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/seed_db.sql
    echo "✓ seed_db.sql ejecutado exitosamente."
else
    echo "✗ ERROR: seed_db.sql no encontrado"
    exit 1
fi

echo "=========================================="
echo "Inicialización completada exitosamente"
echo "=========================================="

