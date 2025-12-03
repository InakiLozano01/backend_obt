#!/bin/bash
# Script de inicialización de MySQL
# Este script ejecuta init_db.sql y seed_db.sql cuando MySQL está listo
# Se ejecuta cada vez que el contenedor mysql-init se inicia

set -e

MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"
INIT_ON_RESTART="${INIT_ON_RESTART:-true}"

echo "=========================================="
echo "Script de inicialización de MySQL"
echo "Host MySQL: ${MYSQL_HOST}"
echo "INIT_ON_RESTART: ${INIT_ON_RESTART}"
echo "=========================================="

# Verificar si se debe ejecutar la inicialización
if [ "${INIT_ON_RESTART}" != "true" ]; then
    echo "INIT_ON_RESTART=false - Saltando inicialización."
    exit 0
fi

# Esperar a que MySQL esté disponible
echo "Esperando a que MySQL esté listo..."
max_attempts=30
attempt=0
until mysqladmin ping -h "${MYSQL_HOST}" -u root -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "✗ ERROR: MySQL no está disponible después de $max_attempts intentos"
        exit 1
    fi
    echo "Esperando MySQL en ${MYSQL_HOST}... (intento $attempt/$max_attempts)"
    sleep 2
done

echo "✓ MySQL está listo. Ejecutando scripts de inicialización..."

# Ejecutar init_db.sql
if [ -f /scripts/init_db.sql ]; then
    echo "Ejecutando init_db.sql..."
    mysql -h "${MYSQL_HOST}" -u root -p"${MYSQL_ROOT_PASSWORD}" < /scripts/init_db.sql
    echo "✓ init_db.sql ejecutado exitosamente."
else
    echo "✗ ERROR: init_db.sql no encontrado en /scripts/"
    exit 1
fi

# Ejecutar seed_db.sql
if [ -f /scripts/seed_db.sql ]; then
    echo "Ejecutando seed_db.sql..."
    mysql -h "${MYSQL_HOST}" -u root -p"${MYSQL_ROOT_PASSWORD}" < /scripts/seed_db.sql
    echo "✓ seed_db.sql ejecutado exitosamente."
else
    echo "✗ ERROR: seed_db.sql no encontrado en /scripts/"
    exit 1
fi

echo "=========================================="
echo "✓ Inicialización completada exitosamente"
echo "=========================================="

# Mantener el contenedor vivo para evitar reinicio en loop
# El contenedor se reiniciará cuando MySQL se reinicie (dependencia de healthcheck)
echo "Contenedor en espera. Se reiniciará si MySQL se reinicia."
exec sleep infinity
