# 🎬 Cinema API - Test Commands

Este documento contiene todos los comandos curl para testear los endpoints de la API del sistema de cine.

## 📑 Índice

- [Endpoints Disponibles](#endpoints-disponibles)
- [1. Precios](#1-precios---obtener-precio-de-función)
- [2. Reservas - Crear](#2-reservas---crear-reserva)
- [3. Reservas - Listar por DNI](#3-reservas---listar-por-dni)
- [4. Reporte de Ocupación](#4-reporte---ocupación-por-película)
- [Datos de Referencia](#datos-de-referencia)

---

## Endpoints Disponibles

| Método | Endpoint                       | Descripción                             |
| ------ | ------------------------------ | --------------------------------------- |
| GET    | `/api/v1/precios/{id_funcion}` | Obtener precio calculado de una función |
| POST   | `/api/v1/reservas`             | Crear una nueva reserva                 |
| GET    | `/api/v1/reservas/{dni}`       | Listar reservas por DNI                 |
| GET    | `/api/v1/reporte/ocupacion`    | Reporte de ocupación por película       |

---

## 1. PRECIOS - Obtener Precio de Función

El SP `SP_DeterminarPrecioEntrada` calcula el precio final aplicando:

- **+10%** si el género es "Estreno" o "3D"
- **+5%** si la sala es VIP (IdSala=1)

### ✅ Casos Exitosos

```bash
# Precio para Estreno + VIP (aplica +10% + 5% = +15.5%) - Función 1: Avatar 3 en Sala VIP, precio base 1500
curl -X GET "http://localhost:5000/api/v1/precios/1"

# Precio para Estreno en sala estándar (solo +10%) - Función 4: Avatar 3 en Sala 1, precio base 1200
curl -X GET "http://localhost:5000/api/v1/precios/4"

# Precio para película 3D (solo +10%) - Función 7: Jurassic World 4 en Sala 3D, precio base 1100
curl -X GET "http://localhost:5000/api/v1/precios/7"

# Precio para función normal (sin recargos) - Función 9: Misión Imposible en Sala 1, precio base 1000
curl -X GET "http://localhost:5000/api/v1/precios/9"

# Precio para función en IMAX (sin recargo especial) - Función 13: Odisea Espacial en Sala IMAX, precio base 1400
curl -X GET "http://localhost:5000/api/v1/precios/13"
```

### ❌ Casos de Error

```bash
# ERROR 404: Función no encontrada
curl -X GET "http://localhost:5000/api/v1/precios/9999"

# ERROR 400: Función finalizada (FechaFin NOT NULL) - Función 20 ya terminó
curl -X GET "http://localhost:5000/api/v1/precios/20"

# ERROR 400: Función finalizada - Función 21 ya terminó
curl -X GET "http://localhost:5000/api/v1/precios/21"

# ERROR 400: Función inactiva (Estado='I') - Función 22 está cancelada
curl -X GET "http://localhost:5000/api/v1/precios/22"

# ERROR 400: Función inactiva - Función 23 está cancelada
curl -X GET "http://localhost:5000/api/v1/precios/23"
```

---

## 2. RESERVAS - Crear Reserva

El SP `SP_ReservarButacaConValidacionDNI` valida:

- Función debe existir y estar activa
- Butaca debe existir y pertenecer a la sala de la función
- Butaca no debe estar ya reservada para esa función
- DNI no puede tener más de 4 reservas activas y pagadas en la misma fecha

### ✅ Casos Exitosos

```bash
# Función 1 (Sala VIP) - butaca 20 está libre
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 1, \"id_butaca\": 20, \"dni\": \"99887766\"}"

# Función 3 (Sala VIP) - butaca 25 está libre
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 3, \"id_butaca\": 25, \"dni\": \"55554444\"}"

# Función 9 (Sala 1) - butaca 70 está libre (rango 51-130)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9, \"id_butaca\": 70, \"dni\": \"99887766\"}"

# Función 10 (Sala 2) - butaca 150 está libre (rango 131-210)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 10, \"id_butaca\": 150, \"dni\": \"11112222\"}"

# Función 7 (Sala 3D) - butaca 480 está libre (rango 471-550)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 7, \"id_butaca\": 480, \"dni\": \"66665555\"}"

# Función 13 (Sala IMAX) - butaca 400 está libre (rango 371-470)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 13, \"id_butaca\": 400, \"dni\": \"77776666\"}"

# Función 15 (Sala Premium) - butaca 560 está libre (rango 551-610)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 15, \"id_butaca\": 560, \"dni\": \"88887777\"}"
```

### ❌ Error 409: Límite de 4 reservas por DNI excedido

```bash
# DNI 12345678 ya tiene 4 reservas pagadas para el 2025-12-20
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 1, \"id_butaca\": 20, \"dni\": \"12345678\"}"

# DNI 33445566 ya tiene 4 reservas pagadas para el 2025-12-20
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 4, \"id_butaca\": 70, \"dni\": \"33445566\"}"

# DNI 00112233 ya tiene 4 reservas pagadas para el 2025-12-22
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 14, \"id_butaca\": 390, \"dni\": \"00112233\"}"
```

### ❌ Error 409: Butaca ya reservada

```bash
# Butaca 1 ya está reservada para función 1
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 1, \"id_butaca\": 1, \"dni\": \"99999999\"}"

# Butaca 2 ya está reservada para función 1
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 1, \"id_butaca\": 2, \"dni\": \"99999999\"}"

# Butaca 51 ya está reservada para función 4
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 4, \"id_butaca\": 51, \"dni\": \"99999999\"}"

# Butaca 371 ya está reservada para función 13
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 13, \"id_butaca\": 371, \"dni\": \"99999999\"}"
```

### ❌ Error 404/400: Función no encontrada o inválida

```bash
# Función no existe
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9999, \"id_butaca\": 1, \"dni\": \"12345678\"}"

# Función inactiva (Estado='I')
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 22, \"id_butaca\": 220, \"dni\": \"12345678\"}"

# Función finalizada (FechaFin NOT NULL)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 20, \"id_butaca\": 70, \"dni\": \"12345678\"}"
```

### ❌ Error 400: Butaca no pertenece a la sala

```bash
# Función 9 es en Sala 1 (IdButaca 51-130), butaca 1 está en Sala VIP
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9, \"id_butaca\": 1, \"dni\": \"12345678\"}"

# Función 1 es en Sala VIP (IdButaca 1-50), butaca 100 está en Sala 1
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 1, \"id_butaca\": 100, \"dni\": \"12345678\"}"

# Función 7 es en Sala 3D (IdButaca 471-550), butaca 300 está en Sala 4
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 7, \"id_butaca\": 300, \"dni\": \"12345678\"}"
```

### ❌ Error 400: Validación de datos

```bash
# DNI muy corto (mínimo 7 caracteres)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9, \"id_butaca\": 70, \"dni\": \"123\"}"

# DNI muy largo (máximo 11 caracteres)
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9, \"id_butaca\": 70, \"dni\": \"123456789012\"}"

# Falta campo dni
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9, \"id_butaca\": 70}"

# Falta campo id_funcion
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_butaca\": 70, \"dni\": \"12345678\"}"

# Falta campo id_butaca
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{\"id_funcion\": 9, \"dni\": \"12345678\"}"

# Body vacío
curl -X POST "http://localhost:5000/api/v1/reservas" -H "Content-Type: application/json" -d "{}"
```

---

## 3. RESERVAS - Listar por DNI

El SP `SP_ReservasPorDNI` devuelve todas las reservas de un cliente.

### ✅ Casos Exitosos

```bash
# DNI con múltiples reservas (12345678 tiene 6 reservas)
curl -X GET "http://localhost:5000/api/v1/reservas/12345678"

# Con paginación
curl -X GET "http://localhost:5000/api/v1/reservas/12345678?page=1&per_page=2"

# Segunda página
curl -X GET "http://localhost:5000/api/v1/reservas/12345678?page=2&per_page=2"

# DNI 87654321 (tiene 2 reservas: 1 pagada, 1 no pagada)
curl -X GET "http://localhost:5000/api/v1/reservas/87654321"

# DNI 11223344 (tiene reserva cancelada y activas)
curl -X GET "http://localhost:5000/api/v1/reservas/11223344"

# DNI 33445566 (4 reservas pagadas - al límite)
curl -X GET "http://localhost:5000/api/v1/reservas/33445566"

# DNI 77889900 (reservas en IMAX y Sala 3)
curl -X GET "http://localhost:5000/api/v1/reservas/77889900"

# DNI 88990011 (reservas en IMAX y Sala 3)
curl -X GET "http://localhost:5000/api/v1/reservas/88990011"

# DNI 00112233 (4 reservas pagadas - al límite para 22/12)
curl -X GET "http://localhost:5000/api/v1/reservas/00112233"

# DNI 55667788 (reservas pagadas)
curl -X GET "http://localhost:5000/api/v1/reservas/55667788"

# DNI 66778899 (reservas mixtas)
curl -X GET "http://localhost:5000/api/v1/reservas/66778899"

# DNI sin reservas (resultado vacío)
curl -X GET "http://localhost:5000/api/v1/reservas/00000000"

# Otro DNI sin reservas
curl -X GET "http://localhost:5000/api/v1/reservas/99999999"
```

### Paginación

```bash
# 5 elementos por página
curl -X GET "http://localhost:5000/api/v1/reservas/12345678?per_page=5"

# Página específica
curl -X GET "http://localhost:5000/api/v1/reservas/12345678?page=1&per_page=3"

# Máximo por página (100)
curl -X GET "http://localhost:5000/api/v1/reservas/12345678?per_page=100"
```

---

## 4. REPORTE - Ocupación por Película

El SP `SP_ReporteOcupacionPorPelicula` genera un reporte con:

- Funciones activas de una película en un rango de fechas
- Total de butacas vendidas (reservas activas y pagadas)
- Total de ingresos recaudados

### ✅ Casos Exitosos

```bash
# Reporte Avatar 3 (IdPelicula=1) - Diciembre 2025
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Matrix 5 (IdPelicula=2)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=2&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Dune Parte 3 (IdPelicula=3)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=3&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Jurassic World 4 - 3D (IdPelicula=4)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=4&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Misión Imposible (IdPelicula=6) - tiene varias funciones
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=6&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Comedia (IdPelicula=7)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=7&fechaInicio=2025-12-20&fechaFin=2025-12-25"

# Reporte Drama (IdPelicula=8)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=8&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Terror (IdPelicula=9)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=9&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Odisea Espacial IMAX (IdPelicula=10)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=10&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Aventuras Animadas (IdPelicula=11)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=11&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Reporte Amor en París (IdPelicula=12)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=12&fechaInicio=2025-12-01&fechaFin=2025-12-31"
```

### Paginación

```bash
# Con paginación
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=6&fechaInicio=2025-12-01&fechaFin=2025-12-31&page=1&per_page=2"

# Segunda página
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=6&fechaInicio=2025-12-01&fechaFin=2025-12-31&page=2&per_page=2"
```

### Casos con resultados vacíos

```bash
# Película sin funciones en el rango de fechas
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=2024-01-01&fechaFin=2024-12-31"

# Película inexistente
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=999&fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Rango de fechas futuro sin funciones
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=2026-01-01&fechaFin=2026-12-31"
```

### ❌ Casos de Error

```bash
# Falta idPelicula
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?fechaInicio=2025-12-01&fechaFin=2025-12-31"

# Falta fechaInicio
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaFin=2025-12-31"

# Falta fechaFin
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=2025-12-01"

# Formato de fecha inválido (DD-MM-YYYY en vez de YYYY-MM-DD)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=01-12-2025&fechaFin=31-12-2025"

# Formato de fecha inválido (con barras)
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion?idPelicula=1&fechaInicio=2025/12/01&fechaFin=2025/12/31"

# Sin parámetros
curl -X GET "http://localhost:5000/api/v1/reporte/ocupacion"
```

---

## Datos de Referencia

### Distribución de Butacas por Sala

| Sala         | IdSala | Rango IdButaca | Total |
| ------------ | ------ | -------------- | ----- |
| Sala VIP     | 1      | 1 - 50         | 50    |
| Sala 1       | 2      | 51 - 130       | 80    |
| Sala 2       | 3      | 131 - 210      | 80    |
| Sala 3       | 4      | 211 - 290      | 80    |
| Sala 4       | 5      | 291 - 370      | 80    |
| Sala IMAX    | 6      | 371 - 470      | 100   |
| Sala 3D      | 7      | 471 - 550      | 80    |
| Sala Premium | 8      | 551 - 610      | 60    |

### Funciones y sus Salas

| IdFuncion | Película         | IdSala | Sala    | Rango Butacas | Estado        |
| --------- | ---------------- | ------ | ------- | ------------- | ------------- |
| 1         | Avatar 3         | 1      | VIP     | 1-50          | ✅ Activa     |
| 2         | Matrix 5         | 1      | VIP     | 1-50          | ✅ Activa     |
| 3         | Dune 3           | 1      | VIP     | 1-50          | ✅ Activa     |
| 4         | Avatar 3         | 2      | Sala 1  | 51-130        | ✅ Activa     |
| 5         | Matrix 5         | 3      | Sala 2  | 131-210       | ✅ Activa     |
| 6         | Dune 3           | 4      | Sala 3  | 211-290       | ✅ Activa     |
| 7         | Jurassic 3D      | 7      | Sala 3D | 471-550       | ✅ Activa     |
| 8         | Spider-Man 3D    | 7      | Sala 3D | 471-550       | ✅ Activa     |
| 9         | Misión Imposible | 2      | Sala 1  | 51-130        | ✅ Activa     |
| 10        | Comedia          | 3      | Sala 2  | 131-210       | ✅ Activa     |
| 11        | Drama            | 4      | Sala 3  | 211-290       | ✅ Activa     |
| 12        | Terror           | 5      | Sala 4  | 291-370       | ✅ Activa     |
| 13        | Odisea IMAX      | 6      | IMAX    | 371-470       | ✅ Activa     |
| 14        | Animación IMAX   | 6      | IMAX    | 371-470       | ✅ Activa     |
| 15        | Amor en París    | 8      | Premium | 551-610       | ✅ Activa     |
| 16-19     | Varias           | Varias | Varias  | Varias        | ✅ Activa     |
| 20        | Misión Imposible | 2      | Sala 1  | 51-130        | ❌ Finalizada |
| 21        | Comedia          | 3      | Sala 2  | 131-210       | ❌ Finalizada |
| 22        | Drama            | 4      | Sala 3  | 211-290       | ❌ Inactiva   |
| 23        | Terror           | 5      | Sala 4  | 291-370       | ❌ Inactiva   |

### Butacas Ocupadas por Función

| Función | Sala    | Butacas Reservadas           | DNIs                         |
| ------- | ------- | ---------------------------- | ---------------------------- |
| 1       | VIP     | 1, 2, 3, 4, 5, 6, 7\*, 8     | 12345678, 87654321, 11223344 |
| 2       | VIP     | 10, 11, 12                   | 12345678, 22334455           |
| 4       | Sala 1  | 51, 52, 53, 54, 55           | 33445566, 44556677           |
| 9       | Sala 1  | 56, 57, 58, 59               | 55667788, 66778899           |
| 10      | Sala 2  | 131, 132, 133                | 44556677, 55667788           |
| 11      | Sala 3  | 211, 212, 213, 214, 215      | 66778899, 77889900, 88990011 |
| 12      | Sala 4  | 291, 292, 293                | 99001122, 00112233           |
| 13      | IMAX    | 371, 372, 373, 374, 375, 376 | 77889900, 88990011, 99001122 |
| 14      | IMAX    | 380, 381, 382, 383           | 00112233                     |
| 15      | Premium | 551, 552                     | 11223344                     |
| 16      | Sala 1  | 60, 61, 62                   | 12345678, 22334455           |

> \* Butaca 7 está **cancelada** (FechaBaja NOT NULL), por lo que técnicamente está disponible

### DNIs con Reservas en el Sistema

| DNI        | Reservas | Estado                         |
| ---------- | -------- | ------------------------------ |
| `12345678` | 6        | ⚠️ 4 pagadas el 20/12 (LÍMITE) |
| `87654321` | 2        | 1 pagada, 1 no pagada          |
| `11223344` | 3        | 1 cancelada, 2 activas         |
| `22334455` | 3        | 2 pagadas, 1 no pagada         |
| `33445566` | 4        | ⚠️ 4 pagadas el 20/12 (LÍMITE) |
| `44556677` | 3        | Todas pagadas                  |
| `55667788` | 3        | Todas pagadas                  |
| `66778899` | 4        | 2 pagadas, 2 no pagadas        |
| `77889900` | 4        | Todas pagadas                  |
| `88990011` | 4        | Todas pagadas                  |
| `99001122` | 3        | 2 pagadas, 1 no pagada         |
| `00112233` | 5        | ⚠️ 4 pagadas el 22/12 (LÍMITE) |

### Reglas de Precio

```
Precio Final = Precio Base × (1 + Recargo Género) × (1 + Recargo Sala)

Recargo Género:
- Estreno: +10%
- 3D: +10%
- Otros: 0%

Recargo Sala:
- VIP (IdSala=1): +5%
- Otras: 0%

Ejemplos:
- Función 1 (Estreno + VIP): 1500 × 1.10 × 1.05 = $1732.50
- Función 4 (Estreno): 1200 × 1.10 = $1320
- Función 9 (Normal): 1000 × 1.00 = $1000
```

---

## Scripts de Prueba Rápida

### Bash - Probar todos los endpoints

```bash
#!/bin/bash
BASE_URL="http://localhost:5000/api/v1"

echo "=== Testing Precios ==="
curl -s "$BASE_URL/precios/1" | jq .
curl -s "$BASE_URL/precios/9999" | jq .

echo "=== Testing Reservas GET ==="
curl -s "$BASE_URL/reservas/12345678" | jq .

echo "=== Testing Reservas POST ==="
curl -s -X POST "$BASE_URL/reservas" -H "Content-Type: application/json" -d '{"id_funcion": 1, "id_butaca": 25, "dni": "99998888"}' | jq .

echo "=== Testing Reporte ==="
curl -s "$BASE_URL/reporte/ocupacion?idPelicula=1&fechaInicio=2025-12-01&fechaFin=2025-12-31" | jq .
```

### PowerShell - Probar todos los endpoints

```powershell
$BASE_URL = "http://localhost:5000/api/v1"

Write-Host "=== Testing Precios ===" -ForegroundColor Green
Invoke-RestMethod -Uri "$BASE_URL/precios/1" | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/precios/9999" -ErrorAction SilentlyContinue

Write-Host "=== Testing Reservas GET ===" -ForegroundColor Green
Invoke-RestMethod -Uri "$BASE_URL/reservas/12345678" | ConvertTo-Json

Write-Host "=== Testing Reservas POST ===" -ForegroundColor Green
$body = '{"id_funcion": 1, "id_butaca": 25, "dni": "99997777"}'
Invoke-RestMethod -Uri "$BASE_URL/reservas" -Method Post -Body $body -ContentType "application/json" | ConvertTo-Json

Write-Host "=== Testing Reporte ===" -ForegroundColor Green
Invoke-RestMethod -Uri "$BASE_URL/reporte/ocupacion?idPelicula=1&fechaInicio=2025-12-01&fechaFin=2025-12-31" | ConvertTo-Json
```

---

## Notas Importantes

1. **Límite de 4 reservas**: Un DNI no puede tener más de 4 reservas **activas** (FechaBaja IS NULL) y **pagadas** (EstaPagada='S') en la **misma fecha**.

2. **Funciones válidas**: Solo se pueden hacer reservas en funciones:

   - Con Estado = 'A' (Activa)
   - Con FechaFin IS NULL (No finalizada)

3. **Butacas**: Cada butaca tiene un IdButaca único global. Usar el rango correcto según la sala de la función.

4. **Reservas canceladas**: Una reserva con FechaBaja NOT NULL libera la butaca para que pueda ser reservada nuevamente.

5. **Formato de fechas**: Siempre usar `YYYY-MM-DD` para los parámetros de fecha.
