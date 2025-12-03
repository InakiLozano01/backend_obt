/* =========================================================
   0) Drop & create DB / schema
   ========================================================= */

DROP DATABASE IF EXISTS cine_db;

CREATE DATABASE cine_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cine_db;

/* =========================================================
   1) Tablas (con PK AUTO_INCREMENT + CHECKs + UNIQUEs)
   ========================================================= */

CREATE TABLE IF NOT EXISTS Generos (
    IdGenero      SMALLINT      NOT NULL AUTO_INCREMENT,
    Genero        VARCHAR(50)   NOT NULL,
    Estado        CHAR(1)       NOT NULL,
    CONSTRAINT PK_Generos PRIMARY KEY (IdGenero),
    CONSTRAINT UQ_Generos_Genero UNIQUE (Genero),
    CONSTRAINT CHK_Generos_Estado CHECK (Estado IN ('A','I'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS Salas (
    IdSala         SMALLINT      NOT NULL AUTO_INCREMENT,
    Sala           VARCHAR(60)   NOT NULL,
    TipoSala       CHAR(1)       NOT NULL,
    Direccion      VARCHAR(60)   NOT NULL,
    Estado         CHAR(1)       NOT NULL,
    Observaciones  VARCHAR(255)  NULL,
    CONSTRAINT PK_Salas PRIMARY KEY (IdSala),
    CONSTRAINT UQ_Salas_Sala UNIQUE (Sala),
    CONSTRAINT CHK_Salas_Estado CHECK (Estado IN ('A','I'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS Peliculas (
    IdPelicula     INT           NOT NULL AUTO_INCREMENT,
    IdGenero       SMALLINT      NOT NULL,
    Pelicula       VARCHAR(100)  NOT NULL,
    Sinopsis       TEXT          NOT NULL,
    Duracion       SMALLINT      NOT NULL,
    Actores        TEXT          NOT NULL,
    Estado         CHAR(1)       NOT NULL,
    Observaciones  VARCHAR(255)  NULL,
    CONSTRAINT PK_Peliculas PRIMARY KEY (IdPelicula),
    CONSTRAINT UQ_Peliculas_Pelicula UNIQUE (Pelicula),
    CONSTRAINT CHK_Peliculas_Estado CHECK (Estado IN ('A','I')),
    CONSTRAINT FK_Peliculas_Generos
        FOREIGN KEY (IdGenero)
        REFERENCES Generos (IdGenero)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS Butacas (
    IdButaca       INT           NOT NULL AUTO_INCREMENT,
    IdSala         SMALLINT      NOT NULL,
    NroButaca      SMALLINT      NOT NULL,
    Fila           SMALLINT      NOT NULL,
    Columna        SMALLINT      NOT NULL,
    Estado         CHAR(1)       NOT NULL,
    Observaciones  VARCHAR(255)  NULL,
    CONSTRAINT PK_Butacas PRIMARY KEY (IdButaca),
    -- nombre "lógico" de butaca = NroButaca dentro de una sala
    CONSTRAINT UQ_Butacas_Nro_Sala UNIQUE (IdSala, NroButaca),
    CONSTRAINT CHK_Butacas_Estado CHECK (Estado IN ('A','I')),
    CONSTRAINT FK_Butacas_Salas
        FOREIGN KEY (IdSala)
        REFERENCES Salas (IdSala)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS Funciones (
    IdFuncion           INT           NOT NULL AUTO_INCREMENT,
    IdPelicula          INT           NOT NULL,
    IdSala              SMALLINT      NOT NULL,
    FechaProbableInicio DATETIME      NOT NULL,
    FechaProbableFin    DATETIME      NOT NULL,
    FechaInicio         DATETIME      NOT NULL,
    FechaFin            DATETIME      NULL,
    Precio              DECIMAL(12,2) NOT NULL,
    Estado              CHAR(1)       NOT NULL,
    Observaciones       VARCHAR(255)  NULL,
    CONSTRAINT PK_Funciones PRIMARY KEY (IdFuncion),
    CONSTRAINT CHK_Funciones_Precio CHECK (Precio > 0),
    CONSTRAINT CHK_Funciones_Estado CHECK (Estado IN ('A','I')),
    CONSTRAINT CHK_Funciones_FechasProbables
        CHECK (FechaProbableInicio <= FechaProbableFin),
    CONSTRAINT CHK_Funciones_FechasReales
        CHECK (FechaFin IS NULL OR FechaInicio < FechaFin),
    CONSTRAINT FK_Funciones_Peliculas
        FOREIGN KEY (IdPelicula)
        REFERENCES Peliculas (IdPelicula)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT FK_Funciones_Salas
        FOREIGN KEY (IdSala)
        REFERENCES Salas (IdSala)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS Reservas (
    IdReserva     BIGINT        NOT NULL AUTO_INCREMENT,
    IdFuncion     INT           NOT NULL,
    IdPelicula    INT           NOT NULL,
    IdSala        SMALLINT      NOT NULL,
    IdButaca      INT           NOT NULL,
    DNI           VARCHAR(11)   NOT NULL,
    FechaAlta     DATETIME      NOT NULL,
    FechaBaja     DATETIME      NULL,
    EstaPagada    CHAR(1)       NOT NULL,
    Observaciones VARCHAR(255)  NULL,
    CONSTRAINT PK_Reservas PRIMARY KEY (IdReserva),
    CONSTRAINT CHK_Reservas_EstaPagada CHECK (EstaPagada IN ('S','N')),
    CONSTRAINT FK_Reservas_Funciones
        FOREIGN KEY (IdFuncion)
        REFERENCES Funciones (IdFuncion)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT FK_Reservas_Peliculas
        FOREIGN KEY (IdPelicula)
        REFERENCES Peliculas (IdPelicula)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT FK_Reservas_Salas
        FOREIGN KEY (IdSala)
        REFERENCES Salas (IdSala)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT FK_Reservas_Butacas
        FOREIGN KEY (IdButaca)
        REFERENCES Butacas (IdButaca)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* =========================================================
   2) Índices
   ========================================================= */

-- Crear índices
-- Nota: Como hacemos DROP DATABASE antes, los índices no existen, así que podemos crearlos directamente
CREATE INDEX IDX_Funciones_FechaInicio ON Funciones (FechaInicio);

CREATE INDEX IDX_Reservas_IdFuncion_IdButaca ON Reservas (IdFuncion, IdButaca);

-- índices útiles adicionales sobre FKs
CREATE INDEX IDX_Reservas_DNI ON Reservas (DNI);
CREATE INDEX IDX_Reservas_IdPelicula ON Reservas (IdPelicula);
CREATE INDEX IDX_Reservas_IdSala ON Reservas (IdSala);


/* =========================================================
   3) Stored Procedures
   ========================================================= */

DELIMITER $$

/* 2.1 – SP: Determinar Precio de Entrada */
DROP PROCEDURE IF EXISTS SP_DeterminarPrecioEntrada;
CREATE PROCEDURE SP_DeterminarPrecioEntrada (
    IN  pIdFuncion    INT,
    OUT pPrecioFinal  DECIMAL(12,2),
    OUT pMensaje      VARCHAR(255)
)
proc: BEGIN
    DECLARE vPrecioBase DECIMAL(12,2);
    DECLARE vGenero     VARCHAR(50);
    DECLARE vIdSala     SMALLINT;
    DECLARE vEstado     CHAR(1);
    DECLARE vFechaFin   DATETIME;
    DECLARE v_not_found BOOL DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = TRUE;

    SET pPrecioFinal = NULL;
    SET pMensaje     = NULL;

    SELECT f.Precio, g.Genero, f.IdSala, f.Estado, f.FechaFin
      INTO vPrecioBase, vGenero, vIdSala, vEstado, vFechaFin
    FROM Funciones f
    JOIN Peliculas p  ON p.IdPelicula = f.IdPelicula
    JOIN Generos  g   ON g.IdGenero   = p.IdGenero
    WHERE f.IdFuncion = pIdFuncion;

    IF v_not_found THEN
        SET pMensaje = 'Funcion no encontrada';
        LEAVE proc;
    END IF;

    -- Solo funciones activas y no finalizadas (FechaFin NULL)
    IF vEstado <> 'A' OR vFechaFin IS NOT NULL THEN
        SET pMensaje = 'Funcion inactiva o finalizada';
        LEAVE proc;
    END IF;

    SET pPrecioFinal = vPrecioBase;

    -- Regla 1: género especial => +10%
    IF vGenero IN ('Estreno','3D') THEN
        SET pPrecioFinal = pPrecioFinal * 1.10;
    END IF;

    -- Regla 2: sala VIP (IdSala = 1) => +5%
    IF vIdSala = 1 THEN
        SET pPrecioFinal = pPrecioFinal * 1.05;
    END IF;

    -- Regla 3: no puede ser menor al precio base
    IF pPrecioFinal < vPrecioBase THEN
        SET pPrecioFinal = vPrecioBase;
    END IF;

    SET pMensaje = 'OK';
END$$


/* 2.2 – SP: Reporte de Ocupación por Película */
DROP PROCEDURE IF EXISTS SP_ReporteOcupacionPorPelicula;
CREATE PROCEDURE SP_ReporteOcupacionPorPelicula (
    IN pIdPelicula  INT,
    IN pFechaInicio DATE,
    IN pFechaFin    DATE
)
BEGIN
    SELECT
        f.IdFuncion,
        f.FechaInicio,
        f.IdSala,
        s.Sala,
        COUNT(r.IdReserva) AS TotalButacasVendidas,
        COUNT(r.IdReserva) * f.Precio AS TotalIngresosRecaudados
    FROM Funciones f
    JOIN Salas s     ON s.IdSala = f.IdSala
    LEFT JOIN Reservas r
           ON r.IdFuncion = f.IdFuncion
          AND r.FechaBaja IS NULL
          AND r.EstaPagada = 'S'
    WHERE f.IdPelicula = pIdPelicula
      AND f.Estado = 'A'
      AND DATE(f.FechaInicio) BETWEEN pFechaInicio AND pFechaFin
    GROUP BY f.IdFuncion, f.FechaInicio, f.IdSala, s.Sala, f.Precio
    ORDER BY f.FechaInicio;
END$$


/* 2.3 – SP: Reservar Butaca con Validación de DNI Único */
CREATE PROCEDURE SP_ReservarButacaConValidacionDNI (
    IN  pIdFuncion INT,
    IN  pIdButaca  INT,
    IN  pDNI       VARCHAR(11),
    OUT pMensaje   VARCHAR(255)
)
proc: BEGIN
    DECLARE vIdSala         SMALLINT;
    DECLARE vFechaInicio    DATETIME;
    DECLARE vEstadoFuncion  CHAR(1);
    DECLARE vFechaFin       DATETIME;
    DECLARE vCount          INT;
    DECLARE vIdPelicula     INT;
    DECLARE v_not_found     BOOL DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = TRUE;

    SET pMensaje = NULL;

    /* 1) Validar función */
    SELECT IdSala, FechaInicio, Estado, FechaFin, IdPelicula
      INTO vIdSala, vFechaInicio, vEstadoFuncion, vFechaFin, vIdPelicula
    FROM Funciones
    WHERE IdFuncion = pIdFuncion;

    IF v_not_found THEN
        SET pMensaje = 'Funcion no encontrada';
        LEAVE proc;
    END IF;

    IF vEstadoFuncion <> 'A' OR vFechaFin IS NOT NULL THEN
        SET pMensaje = 'Funcion inactiva o finalizada';
        LEAVE proc;
    END IF;

    /* 2) Validar butaca exista y pertenezca a la sala de la función */
    SELECT COUNT(*) INTO vCount
    FROM Butacas
    WHERE IdButaca = pIdButaca
      AND IdSala   = vIdSala;

    IF vCount = 0 THEN
        SET pMensaje = 'Butaca inexistente en la sala de la funcion';
        LEAVE proc;
    END IF;

    /* 3) Butaca no reservada ya para esa función (activa) */
    SELECT COUNT(*) INTO vCount
    FROM Reservas
    WHERE IdFuncion = pIdFuncion
      AND IdButaca  = pIdButaca
      AND FechaBaja IS NULL;

    IF vCount > 0 THEN
        SET pMensaje = 'Butaca ya reservada para esta funcion';
        LEAVE proc;
    END IF;

    /* 4) Regla nueva:
          mismo DNI no puede tener >4 reservas activas y pagadas en la misma fecha */
    SELECT COUNT(*) INTO vCount
    FROM Reservas r
    JOIN Funciones f ON f.IdFuncion = r.IdFuncion
    WHERE r.DNI = pDNI
      AND r.FechaBaja IS NULL
      AND r.EstaPagada = 'S'
      AND DATE(f.FechaInicio) = DATE(vFechaInicio);

    IF vCount >= 4 THEN
        SET pMensaje = 'Limite de 4 reservas activas y pagadas por fecha superado para este DNI';
        LEAVE proc;
    END IF;

    /* 5) Insertar reserva (la marcamos pagada = 'S' para testear la regla) */
    INSERT INTO Reservas (
        IdFuncion, IdPelicula, IdSala, IdButaca,
        DNI, FechaAlta, FechaBaja, EstaPagada, Observaciones
    ) VALUES (
        pIdFuncion, vIdPelicula, vIdSala, pIdButaca,
        pDNI, NOW(), NULL, 'S', NULL
    );

    SET pMensaje = 'OK';
END$$


/* 2.4 – SP adicional: Listar reservas por DNI */
CREATE PROCEDURE SP_ReservasPorDNI (
    IN pDNI VARCHAR(11)
)
BEGIN
    SELECT
        r.IdReserva,
        r.DNI,
        f.IdFuncion,
        f.FechaInicio,
        p.Pelicula,
        s.Sala,
        r.EstaPagada,
        r.FechaAlta,
        r.FechaBaja
    FROM Reservas r
    JOIN Funciones f ON f.IdFuncion = r.IdFuncion
    JOIN Peliculas p ON p.IdPelicula = f.IdPelicula
    JOIN Salas    s ON s.IdSala     = f.IdSala
    WHERE r.DNI = pDNI
    ORDER BY f.FechaInicio;
END$$

DELIMITER ;
