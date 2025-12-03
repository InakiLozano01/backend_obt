/* =========================================================
   Script de Seeding - Datos de Prueba para cine_db
   =========================================================
   
   Este script:
   1. Trunca todas las tablas en el orden correcto (respetando FK)
   2. Resetea AUTO_INCREMENT a 1
   3. Inserta datos de prueba consistentes
   ========================================================= */

USE cine_db;

/* =========================================================
   1) LIMPIAR TABLAS Y RESETEAR AUTO_INCREMENT
   ========================================================= */

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Reservas;
TRUNCATE TABLE Funciones;
TRUNCATE TABLE Butacas;
TRUNCATE TABLE Peliculas;
TRUNCATE TABLE Salas;
TRUNCATE TABLE Generos;

SET FOREIGN_KEY_CHECKS = 1;

/* =========================================================
   2) GÉNEROS
   Incluimos "Estreno" y "3D" para probar reglas de precio (+10%)
   ========================================================= */

INSERT INTO Generos (IdGenero, Genero, Estado) VALUES
(1, 'Acción', 'A'),
(2, 'Comedia', 'A'),
(3, 'Drama', 'A'),
(4, 'Terror', 'A'),
(5, 'Ciencia Ficción', 'A'),
(6, 'Estreno', 'A'),        -- Para regla de precio +10%
(7, '3D', 'A'),             -- Para regla de precio +10%
(8, 'Animación', 'A'),
(9, 'Romance', 'A'),
(10, 'Suspenso', 'A'),
(11, 'Documental', 'I');    -- Inactivo para pruebas

/* =========================================================
   3) SALAS
   - Sala VIP (IdSala=1) para probar regla +5%
   - Salas estándar y especiales
   TipoSala: V=VIP, E=Estándar, I=IMAX, D=3D, P=Premium
   ========================================================= */

INSERT INTO Salas (IdSala, Sala, TipoSala, Direccion, Estado, Observaciones) VALUES
(1, 'Sala VIP', 'V', 'Piso 2 - Ala Norte', 'A', 'Sala premium con butacas reclinables - Aplica +5%'),
(2, 'Sala 1', 'E', 'Piso 1 - Ala Sur', 'A', 'Sala estándar'),
(3, 'Sala 2', 'E', 'Piso 1 - Ala Sur', 'A', 'Sala estándar'),
(4, 'Sala 3', 'E', 'Piso 1 - Ala Norte', 'A', 'Sala estándar'),
(5, 'Sala 4', 'E', 'Piso 1 - Ala Norte', 'A', 'Sala estándar'),
(6, 'Sala IMAX', 'I', 'Piso 3 - Central', 'A', 'Sala IMAX - pantalla gigante'),
(7, 'Sala 3D', 'D', 'Piso 2 - Ala Sur', 'A', 'Sala equipada para películas 3D'),
(8, 'Sala Premium', 'P', 'Piso 2 - Central', 'A', 'Sala con servicio de comida en butaca');

/* =========================================================
   4) PELÍCULAS
   - Variedad de géneros para probar reglas de precio
   - Algunas inactivas para pruebas de validación
   ========================================================= */

INSERT INTO Peliculas (IdPelicula, IdGenero, Pelicula, Sinopsis, Duracion, Actores, Estado, Observaciones) VALUES
-- Películas con género Estreno (IdGenero=6) - aplica +10%
(1, 6, 'Avatar 3: El Despertar', 'Jake Sully y Neytiri enfrentan una nueva amenaza que pone en peligro a toda Pandora.', 180, 'Sam Worthington, Zoe Saldaña, Sigourney Weaver', 'A', 'Estreno blockbuster'),
(2, 6, 'Matrix 5: Resurrección', 'Neo regresa a la Matrix para descubrir verdades ocultas sobre su existencia.', 165, 'Keanu Reeves, Carrie-Anne Moss, Yahya Abdul-Mateen II', 'A', 'Estreno de ciencia ficción'),
(3, 6, 'Dune: Parte 3', 'Paul Atreides debe unir a las tribus de Arrakis para enfrentar al Emperador.', 175, 'Timothée Chalamet, Zendaya, Rebecca Ferguson', 'A', 'Estreno épico'),

-- Películas con género 3D (IdGenero=7) - aplica +10%
(4, 7, 'Jurassic World 4', 'Los dinosaurios han escapado y ahora coexisten con los humanos en todo el mundo.', 130, 'Chris Pratt, Bryce Dallas Howard, Sam Neill', 'A', 'Película 3D'),
(5, 7, 'Spider-Man: Beyond', 'Peter Parker enfrenta amenazas de múltiples dimensiones en esta aventura épica.', 140, 'Tom Holland, Tobey Maguire, Andrew Garfield', 'A', 'Película 3D'),

-- Películas con géneros normales (sin recargo)
(6, 1, 'Misión Imposible 8', 'Ethan Hunt debe evitar una catástrofe global en su misión más peligrosa.', 155, 'Tom Cruise, Simon Pegg, Rebecca Ferguson', 'A', 'Acción'),
(7, 2, 'Superhéroes Cómicos', 'Un grupo de superhéroes torpes intenta salvar el mundo sin destruirlo primero.', 105, 'Ryan Reynolds, Will Ferrell, Melissa McCarthy', 'A', 'Comedia'),
(8, 3, 'El Último Adiós', 'Una familia se reúne para despedirse de su patriarca en sus últimos días.', 130, 'Anthony Hopkins, Olivia Colman, Florence Pugh', 'A', 'Drama'),
(9, 4, 'La Casa del Terror', 'Un grupo de amigos pasa la noche en una mansión embrujada con consecuencias mortales.', 95, 'Florence Pugh, Mia Goth, Anya Taylor-Joy', 'A', 'Terror'),
(10, 5, 'Odisea Espacial', 'Una misión a los confines del sistema solar descubre secretos que cambiarán la humanidad.', 140, 'Brad Pitt, Tommy Lee Jones, Liv Tyler', 'A', 'Ciencia Ficción'),
(11, 8, 'Aventuras Animadas', 'Un grupo de animales del bosque emprende un viaje épico para salvar su hogar.', 100, 'Chris Rock, Beyoncé, Eddie Murphy (voces)', 'A', 'Animación'),
(12, 9, 'Amor en París', 'Dos extraños se encuentran en París y viven un romance inesperado.', 115, 'Emma Stone, Ryan Gosling, Marion Cotillard', 'A', 'Romance'),
(13, 10, 'El Espía Silencioso', 'Un agente encubierto debe desenmascarar a un traidor dentro de su propia agencia.', 125, 'Daniel Craig, Ana de Armas, Rami Malek', 'A', 'Suspenso'),

-- Películas inactivas para probar validaciones
(14, 1, 'Película Cancelada', 'Sinopsis de película cancelada para pruebas del sistema.', 120, 'Actor Prueba', 'I', 'Inactiva - para pruebas'),
(15, 11, 'Documental Naturaleza', 'Un recorrido por los ecosistemas más increíbles del planeta.', 90, 'David Attenborough (narrador)', 'A', 'Género inactivo');

/* =========================================================
   5) BUTACAS
   Distribución:
   - Sala VIP (1): 50 butacas (IdButaca 1-50)
   - Sala 1 (2): 80 butacas (IdButaca 51-130)
   - Sala 2 (3): 80 butacas (IdButaca 131-210)
   - Sala 3 (4): 80 butacas (IdButaca 211-290)
   - Sala 4 (5): 80 butacas (IdButaca 291-370)
   - Sala IMAX (6): 100 butacas (IdButaca 371-470)
   - Sala 3D (7): 80 butacas (IdButaca 471-550)
   - Sala Premium (8): 60 butacas (IdButaca 551-610)
   ========================================================= */

-- Sala VIP (IdSala=1) - 50 butacas en 5 filas x 10 columnas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 1, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A',
       CASE WHEN n <= 10 THEN 'Fila VIP delantera' ELSE NULL END
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) b
    ORDER BY n
) numbers WHERE n <= 50;

-- Sala 1 (IdSala=2) - 80 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 2, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) b
    ORDER BY n
) numbers WHERE n <= 80;

-- Sala 2 (IdSala=3) - 80 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 3, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) b
    ORDER BY n
) numbers WHERE n <= 80;

-- Sala 3 (IdSala=4) - 80 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 4, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) b
    ORDER BY n
) numbers WHERE n <= 80;

-- Sala 4 (IdSala=5) - 80 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 5, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) b
    ORDER BY n
) numbers WHERE n <= 80;

-- Sala IMAX (IdSala=6) - 100 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 6, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
    ORDER BY n
) numbers WHERE n <= 100;

-- Sala 3D (IdSala=7) - 80 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 7, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) b
    ORDER BY n
) numbers WHERE n <= 80;

-- Sala Premium (IdSala=8) - 60 butacas
INSERT INTO Butacas (IdSala, NroButaca, Fila, Columna, Estado, Observaciones)
SELECT 8, n, FLOOR((n-1)/10) + 1, ((n-1) % 10) + 1, 'A', NULL
FROM (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
         (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5) b
    ORDER BY n
) numbers WHERE n <= 60;

/* =========================================================
   6) FUNCIONES
   - Funciones activas (Estado='A', FechaFin=NULL)
   - Funciones finalizadas (FechaFin NOT NULL)
   - Funciones inactivas (Estado='I')
   ========================================================= */

INSERT INTO Funciones (IdFuncion, IdPelicula, IdSala, FechaProbableInicio, FechaProbableFin, FechaInicio, FechaFin, Precio, Estado, Observaciones) VALUES
-- Funciones en Sala VIP (IdSala=1) - para probar regla +5%
-- Película Estreno en Sala VIP = +10% (estreno) + 5% (VIP) = +15.5%
(1, 1, 1, '2025-12-20 20:00:00', '2025-12-20 23:00:00', '2025-12-20 20:00:00', NULL, 1500.00, 'A', 'Estreno + VIP'),
(2, 2, 1, '2025-12-21 18:00:00', '2025-12-21 21:00:00', '2025-12-21 18:00:00', NULL, 1800.00, 'A', 'Estreno + VIP'),
(3, 3, 1, '2025-12-22 19:30:00', '2025-12-22 22:30:00', '2025-12-22 19:30:00', NULL, 1600.00, 'A', 'Estreno + VIP'),

-- Funciones con género Estreno en sala estándar (solo +10%)
(4, 1, 2, '2025-12-20 15:00:00', '2025-12-20 18:00:00', '2025-12-20 15:00:00', NULL, 1200.00, 'A', 'Estreno'),
(5, 2, 3, '2025-12-21 16:00:00', '2025-12-21 19:00:00', '2025-12-21 16:00:00', NULL, 1300.00, 'A', 'Estreno'),
(6, 3, 4, '2025-12-22 17:00:00', '2025-12-22 20:00:00', '2025-12-22 17:00:00', NULL, 1250.00, 'A', 'Estreno'),

-- Funciones con género 3D (solo +10%)
(7, 4, 7, '2025-12-20 14:00:00', '2025-12-20 16:10:00', '2025-12-20 14:00:00', NULL, 1100.00, 'A', '3D'),
(8, 5, 7, '2025-12-21 15:30:00', '2025-12-21 17:50:00', '2025-12-21 15:30:00', NULL, 1150.00, 'A', '3D'),

-- Funciones normales (sin recargos especiales)
(9, 6, 2, '2025-12-20 19:00:00', '2025-12-20 21:35:00', '2025-12-20 19:00:00', NULL, 1000.00, 'A', 'Acción estándar'),
(10, 7, 3, '2025-12-20 20:30:00', '2025-12-20 22:15:00', '2025-12-20 20:30:00', NULL, 950.00, 'A', 'Comedia estándar'),
(11, 8, 4, '2025-12-21 18:00:00', '2025-12-21 20:10:00', '2025-12-21 18:00:00', NULL, 1100.00, 'A', 'Drama estándar'),
(12, 9, 5, '2025-12-21 21:00:00', '2025-12-21 22:35:00', '2025-12-21 21:00:00', NULL, 1050.00, 'A', 'Terror estándar'),
(13, 10, 6, '2025-12-22 16:00:00', '2025-12-22 18:20:00', '2025-12-22 16:00:00', NULL, 1400.00, 'A', 'IMAX'),
(14, 11, 6, '2025-12-22 19:00:00', '2025-12-22 20:40:00', '2025-12-22 19:00:00', NULL, 1350.00, 'A', 'IMAX'),
(15, 12, 8, '2025-12-20 17:00:00', '2025-12-20 18:55:00', '2025-12-20 17:00:00', NULL, 1200.00, 'A', 'Premium'),

-- Más funciones para reportes
(16, 6, 2, '2025-12-23 16:00:00', '2025-12-23 18:35:00', '2025-12-23 16:00:00', NULL, 1000.00, 'A', 'Para reporte'),
(17, 6, 3, '2025-12-24 17:00:00', '2025-12-24 19:35:00', '2025-12-24 17:00:00', NULL, 1000.00, 'A', 'Para reporte'),
(18, 7, 4, '2025-12-25 18:00:00', '2025-12-25 19:45:00', '2025-12-25 18:00:00', NULL, 950.00, 'A', 'Para reporte'),
(19, 8, 5, '2025-12-26 19:00:00', '2025-12-26 21:10:00', '2025-12-26 19:00:00', NULL, 1100.00, 'A', 'Para reporte'),

-- Funciones FINALIZADAS (FechaFin NOT NULL) - para probar validaciones
(20, 6, 2, '2025-12-10 20:00:00', '2025-12-10 22:35:00', '2025-12-10 20:00:00', '2025-12-10 22:35:00', 1000.00, 'A', 'Finalizada'),
(21, 7, 3, '2025-12-11 19:00:00', '2025-12-11 20:45:00', '2025-12-11 19:00:00', '2025-12-11 20:45:00', 950.00, 'A', 'Finalizada'),

-- Funciones INACTIVAS (Estado='I') - para probar validaciones
(22, 8, 4, '2025-12-27 18:00:00', '2025-12-27 20:10:00', '2025-12-27 18:00:00', NULL, 1100.00, 'I', 'Cancelada'),
(23, 9, 5, '2025-12-28 19:00:00', '2025-12-28 20:35:00', '2025-12-28 19:00:00', NULL, 1050.00, 'I', 'Cancelada');

/* =========================================================
   7) RESERVAS
   Usando INSERT...SELECT para obtener IdButaca real
   basándose en IdSala y NroButaca
   
   Casos de prueba:
   - Límite de 4 reservas por DNI por fecha
   - Butacas ocupadas
   - Reservas pagadas y no pagadas
   - Reservas canceladas (FechaBaja NOT NULL)
   ========================================================= */

-- Función 1: Avatar 3 en Sala VIP (IdSala=1)
-- DNI 12345678 tiene 4 reservas pagadas (límite)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '12345678', '2025-12-15 10:00:00', NULL, 'S', 'Reserva pagada 1/4'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '12345678', '2025-12-15 10:05:00', NULL, 'S', 'Reserva pagada 2/4'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 2;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '12345678', '2025-12-15 10:10:00', NULL, 'S', 'Reserva pagada 3/4'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 3;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '12345678', '2025-12-15 10:15:00', NULL, 'S', 'Reserva pagada 4/4 - LÍMITE'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 4;

-- Otro DNI en la misma función
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '87654321', '2025-12-15 11:00:00', NULL, 'S', 'Reserva pagada - otro DNI'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 5;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '87654321', '2025-12-15 11:05:00', NULL, 'N', 'Reserva NO pagada'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 6;

-- Reserva cancelada (FechaBaja NOT NULL)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '11223344', '2025-12-15 12:00:00', '2025-12-16 10:00:00', 'S', 'Reserva CANCELADA'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 7;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 1, 1, 1, b.IdButaca, '11223344', '2025-12-15 12:05:00', NULL, 'S', 'Reserva activa después de cancelar otra'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 8;

-- Función 2: Matrix 5 en Sala VIP (IdSala=1)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 2, 2, 1, b.IdButaca, '12345678', '2025-12-15 13:00:00', NULL, 'S', 'Mismo DNI, otra función'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 10;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 2, 2, 1, b.IdButaca, '22334455', '2025-12-15 14:00:00', NULL, 'S', 'Reserva pagada'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 11;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 2, 2, 1, b.IdButaca, '22334455', '2025-12-15 14:05:00', NULL, 'N', 'Reserva NO pagada'
FROM Butacas b WHERE b.IdSala = 1 AND b.NroButaca = 12;

-- Función 4: Avatar 3 en Sala 1 (IdSala=2) - Estreno
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 4, 1, 2, b.IdButaca, '33445566', '2025-12-15 15:00:00', NULL, 'S', 'Reserva pagada 1/4'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 4, 1, 2, b.IdButaca, '33445566', '2025-12-15 15:05:00', NULL, 'S', 'Reserva pagada 2/4'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 2;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 4, 1, 2, b.IdButaca, '33445566', '2025-12-15 15:10:00', NULL, 'S', 'Reserva pagada 3/4'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 3;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 4, 1, 2, b.IdButaca, '33445566', '2025-12-15 15:15:00', NULL, 'S', 'Reserva pagada 4/4 - LÍMITE'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 4;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 4, 1, 2, b.IdButaca, '44556677', '2025-12-15 16:00:00', NULL, 'S', 'Otro DNI'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 5;

-- Función 9: Misión Imposible en Sala 1 (IdSala=2)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 9, 6, 2, b.IdButaca, '55667788', '2025-12-15 17:00:00', NULL, 'S', 'Reserva pagada'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 6;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 9, 6, 2, b.IdButaca, '55667788', '2025-12-15 17:05:00', NULL, 'S', 'Reserva pagada'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 7;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 9, 6, 2, b.IdButaca, '66778899', '2025-12-15 18:00:00', NULL, 'N', 'Reserva NO pagada'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 8;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 9, 6, 2, b.IdButaca, '66778899', '2025-12-15 18:05:00', NULL, 'N', 'Reserva NO pagada'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 9;

-- Función 13: Odisea Espacial en IMAX (IdSala=6)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 13, 10, 6, b.IdButaca, '77889900', '2025-12-15 19:00:00', NULL, 'S', 'Reserva IMAX 1'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 13, 10, 6, b.IdButaca, '77889900', '2025-12-15 19:05:00', NULL, 'S', 'Reserva IMAX 2'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 2;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 13, 10, 6, b.IdButaca, '88990011', '2025-12-15 20:00:00', NULL, 'S', 'Reserva IMAX 3'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 3;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 13, 10, 6, b.IdButaca, '88990011', '2025-12-15 20:05:00', NULL, 'S', 'Reserva IMAX 4'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 4;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 13, 10, 6, b.IdButaca, '88990011', '2025-12-15 20:10:00', NULL, 'S', 'Reserva IMAX 5'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 5;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 13, 10, 6, b.IdButaca, '99001122', '2025-12-15 21:00:00', NULL, 'N', 'Reserva IMAX NO pagada'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 6;

-- Función 14: Aventuras Animadas en IMAX (IdSala=6)
-- DNI 00112233 tiene 4 reservas pagadas (límite)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 14, 11, 6, b.IdButaca, '00112233', '2025-12-15 22:00:00', NULL, 'S', 'Reserva pagada 1/4'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 10;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 14, 11, 6, b.IdButaca, '00112233', '2025-12-15 22:05:00', NULL, 'S', 'Reserva pagada 2/4'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 11;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 14, 11, 6, b.IdButaca, '00112233', '2025-12-15 22:10:00', NULL, 'S', 'Reserva pagada 3/4'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 12;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 14, 11, 6, b.IdButaca, '00112233', '2025-12-15 22:15:00', NULL, 'S', 'Reserva pagada 4/4 - LÍMITE'
FROM Butacas b WHERE b.IdSala = 6 AND b.NroButaca = 13;

-- Función 15: Amor en París en Sala Premium (IdSala=8)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 15, 12, 8, b.IdButaca, '11223344', '2025-12-15 23:00:00', NULL, 'S', 'Reserva Premium 1'
FROM Butacas b WHERE b.IdSala = 8 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 15, 12, 8, b.IdButaca, '11223344', '2025-12-15 23:05:00', NULL, 'S', 'Reserva Premium 2'
FROM Butacas b WHERE b.IdSala = 8 AND b.NroButaca = 2;

-- Reservas adicionales para reportes de ocupación
-- Función 16
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 16, 6, 2, b.IdButaca, '12345678', '2025-12-16 10:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 10;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 16, 6, 2, b.IdButaca, '12345678', '2025-12-16 10:05:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 11;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 16, 6, 2, b.IdButaca, '22334455', '2025-12-16 11:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 2 AND b.NroButaca = 12;

-- Función 10: Comedia en Sala 2 (IdSala=3)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 10, 7, 3, b.IdButaca, '44556677', '2025-12-16 13:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 3 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 10, 7, 3, b.IdButaca, '44556677', '2025-12-16 13:05:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 3 AND b.NroButaca = 2;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 10, 7, 3, b.IdButaca, '55667788', '2025-12-16 14:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 3 AND b.NroButaca = 3;

-- Función 11: Drama en Sala 3 (IdSala=4)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 11, 8, 4, b.IdButaca, '66778899', '2025-12-16 15:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 4 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 11, 8, 4, b.IdButaca, '66778899', '2025-12-16 15:05:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 4 AND b.NroButaca = 2;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 11, 8, 4, b.IdButaca, '77889900', '2025-12-16 16:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 4 AND b.NroButaca = 3;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 11, 8, 4, b.IdButaca, '77889900', '2025-12-16 16:05:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 4 AND b.NroButaca = 4;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 11, 8, 4, b.IdButaca, '88990011', '2025-12-16 17:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 4 AND b.NroButaca = 5;

-- Función 12: Terror en Sala 4 (IdSala=5)
INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 12, 9, 5, b.IdButaca, '99001122', '2025-12-16 18:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 5 AND b.NroButaca = 1;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 12, 9, 5, b.IdButaca, '99001122', '2025-12-16 18:05:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 5 AND b.NroButaca = 2;

INSERT INTO Reservas (IdFuncion, IdPelicula, IdSala, IdButaca, DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones)
SELECT 12, 9, 5, b.IdButaca, '00112233', '2025-12-16 19:00:00', NULL, 'S', 'Para reporte'
FROM Butacas b WHERE b.IdSala = 5 AND b.NroButaca = 3;

/* =========================================================
   8) VERIFICACIÓN DE DATOS
   ========================================================= */

SELECT '=== RESUMEN DE DATOS INSERTADOS ===' AS Info;

SELECT 'Generos' AS Tabla, COUNT(*) AS Registros FROM Generos
UNION ALL SELECT 'Salas', COUNT(*) FROM Salas
UNION ALL SELECT 'Peliculas', COUNT(*) FROM Peliculas
UNION ALL SELECT 'Butacas', COUNT(*) FROM Butacas
UNION ALL SELECT 'Funciones', COUNT(*) FROM Funciones
UNION ALL SELECT 'Reservas', COUNT(*) FROM Reservas;

SELECT '=== DISTRIBUCIÓN DE BUTACAS POR SALA ===' AS Info;

SELECT s.IdSala, s.Sala, COUNT(b.IdButaca) AS TotalButacas,
       MIN(b.IdButaca) AS PrimerIdButaca, MAX(b.IdButaca) AS UltimoIdButaca
FROM Salas s
LEFT JOIN Butacas b ON b.IdSala = s.IdSala
GROUP BY s.IdSala, s.Sala
ORDER BY s.IdSala;

SELECT '=== CASOS DE PRUEBA: LÍMITE 4 RESERVAS POR DNI ===' AS Info;

SELECT r.DNI, DATE(f.FechaInicio) AS Fecha, COUNT(*) AS ReservasActivas
FROM Reservas r
JOIN Funciones f ON f.IdFuncion = r.IdFuncion
WHERE r.FechaBaja IS NULL AND r.EstaPagada = 'S'
GROUP BY r.DNI, DATE(f.FechaInicio)
HAVING COUNT(*) >= 4;

SELECT '=== SEED COMPLETADO EXITOSAMENTE ===' AS Info;
