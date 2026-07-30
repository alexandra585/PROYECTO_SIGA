													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUD CURSOS
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_Cursos')
    DROP PROCEDURE usp_Cursos
GO

CREATE PROCEDURE usp_Cursos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        id,
        codigoCurso,
        nombreCurso,
        creditos,
        horasTeoricas,
        horasPracticas
    FROM tb_cursos
    ORDER BY codigoCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CursoId')
    DROP PROCEDURE usp_CursoId
GO

CREATE PROCEDURE usp_CursoId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        id,
        codigoCurso,
        nombreCurso,
        creditos,
        horasTeoricas,
        horasPracticas
    FROM tb_cursos
    WHERE id = @id;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateCurso')
    DROP PROCEDURE usp_CreateCurso
GO

CREATE PROCEDURE usp_CreateCurso
    @codigoCurso NVARCHAR(20),
    @nombreCurso NVARCHAR(100),
    @creditos INT,
    @horasTeoricas INT,
    @horasPracticas INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_cursos (codigoCurso, nombreCurso, creditos, horasTeoricas, horasPracticas)
    VALUES (@codigoCurso, @nombreCurso, @creditos, @horasTeoricas, @horasPracticas);
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateCurso')
    DROP PROCEDURE usp_UpdateCurso
GO

CREATE PROCEDURE usp_UpdateCurso
    @id INT,
    @codigoCurso NVARCHAR(20),
    @nombreCurso NVARCHAR(100),
    @creditos INT,
    @horasTeoricas INT,
    @horasPracticas INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_cursos 
    SET codigoCurso = @codigoCurso,
        nombreCurso = @nombreCurso,
        creditos = @creditos,
        horasTeoricas = @horasTeoricas,
        horasPracticas = @horasPracticas
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DeleteCurso')
    DROP PROCEDURE usp_DeleteCurso
GO

CREATE PROCEDURE usp_DeleteCurso
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_cursos WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteCodigoCurso')
    DROP PROCEDURE usp_ExisteCodigoCurso
GO

CREATE PROCEDURE usp_ExisteCodigoCurso
    @codigoCurso NVARCHAR(20),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) 
    FROM tb_cursos 
    WHERE codigoCurso = @codigoCurso
    AND (id != @idExcluir OR @idExcluir IS NULL);
END
GO
/*-------------------------------------------------------------------------------------------------*/
