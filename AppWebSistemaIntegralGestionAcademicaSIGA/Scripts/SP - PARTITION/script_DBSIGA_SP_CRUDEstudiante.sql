													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUD ESTUDIANTES
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_Estudiantes')
    DROP PROCEDURE usp_Estudiantes
GO

CREATE PROCEDURE usp_Estudiantes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.activo,
		u.fechaRegistro,
        e.codigoEstudiante, 
        e.nombreCarrera, 
        e.semestreActual
    FROM tb_usuarios u
    INNER JOIN tb_estudiantes e ON u.id = e.id
    WHERE u.rol = 'Estudiante' AND u.activo = 1
    ORDER BY u.id, u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_EstudianteId')
    DROP PROCEDURE usp_EstudianteId
GO

CREATE PROCEDURE usp_EstudianteId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.activo, 
        u.fechaRegistro,
        e.codigoEstudiante, 
        e.nombreCarrera, 
        e.semestreActual
    FROM tb_usuarios u
    INNER JOIN tb_estudiantes e ON u.id = e.id
    WHERE u.id = @id AND u.rol = 'Estudiante';
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateUsuarioEstudiante')
    DROP PROCEDURE usp_CreateUsuarioEstudiante
GO

CREATE PROCEDURE usp_CreateUsuarioEstudiante
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @contrasenia NVARCHAR(255),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
    VALUES (@nombreCompleto, @email, @contrasenia, 'Estudiante', @activo);
    SELECT SCOPE_IDENTITY() AS NuevoId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateEstudiante')
    DROP PROCEDURE usp_CreateEstudiante
GO

CREATE PROCEDURE usp_CreateEstudiante
    @id INT,
    @codigoEstudiante NVARCHAR(20),
    @nombreCarrera NVARCHAR(100),
    @semestreActual INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_estudiantes (id, codigoEstudiante, nombreCarrera, semestreActual)
    VALUES (@id, @codigoEstudiante, @nombreCarrera, @semestreActual);
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateEstudiante')
    DROP PROCEDURE usp_UpdateEstudiante
GO

CREATE PROCEDURE usp_UpdateEstudiante
    @id INT,
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @activo BIT,
    @codigoEstudiante NVARCHAR(20),
    @nombreCarrera NVARCHAR(100),
    @semestreActual INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios 
    SET nombreCompleto = @nombreCompleto, 
        email = @email, 
        activo = @activo
    WHERE id = @id;
    
    UPDATE tb_estudiantes 
    SET codigoEstudiante = @codigoEstudiante,
        nombreCarrera = @nombreCarrera,
        semestreActual = @semestreActual
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DeleteEstudiante')
    DROP PROCEDURE usp_DeleteEstudiante
GO

CREATE PROCEDURE usp_DeleteEstudiante
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_estudiantes WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteCodigoEstudiante')
    DROP PROCEDURE usp_ExisteCodigoEstudiante
GO

CREATE PROCEDURE usp_ExisteCodigoEstudiante
    @codigoEstudiante NVARCHAR(20),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) 
    FROM tb_estudiantes 
    WHERE codigoEstudiante = @codigoEstudiante
    AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteEmailEstudiante')
    DROP PROCEDURE usp_ExisteEmailEstudiante
GO

CREATE PROCEDURE usp_ExisteEmailEstudiante
    @email NVARCHAR(100),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) 
    FROM tb_usuarios 
    WHERE email = @email 
    AND rol = 'Estudiante'
    AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
