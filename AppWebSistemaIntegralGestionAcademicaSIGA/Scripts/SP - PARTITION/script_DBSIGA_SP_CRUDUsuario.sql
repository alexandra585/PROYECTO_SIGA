													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUD USUARIOS
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_Usuarios')
    DROP PROCEDURE usp_Usuarios
GO

CREATE PROCEDURE usp_Usuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.rol, 
        u.activo, 
        u.fechaRegistro, 
        u.numeroIntentos,
        ISNULL(e.codigoEstudiante, '') AS CodigoEstudiante,
        ISNULL(d.especialidad, '') AS Especialidad
    FROM tb_usuarios u
    LEFT JOIN tb_estudiantes e ON u.id = e.id
    LEFT JOIN tb_docentes d ON u.id = d.id
    WHERE u.rol IN ('Director', 'Secretaria', 'Docente', 'Estudiante', 'Apoderado')
    ORDER BY u.id , u.rol, u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UsuarioId')
    DROP PROCEDURE usp_UsuarioId
GO

CREATE PROCEDURE usp_UsuarioId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.rol, 
        u.activo, 
        u.fechaRegistro, 
        u.numeroIntentos,
        ISNULL(e.codigoEstudiante, '') AS CodigoEstudiante,
        ISNULL(d.especialidad, '') AS Especialidad
    FROM tb_usuarios u
    LEFT JOIN tb_estudiantes e ON u.id = e.id
    LEFT JOIN tb_docentes d ON u.id = d.id
    WHERE u.id = @id;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateUsuario')
    DROP PROCEDURE usp_CreateUsuario
GO

CREATE PROCEDURE usp_CreateUsuario
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @contrasenia NVARCHAR(255),
    @rol NVARCHAR(20),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
    VALUES (@nombreCompleto, @email, @contrasenia, @rol, @activo);
    SELECT SCOPE_IDENTITY() AS NuevoId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateUsuario')
    DROP PROCEDURE usp_UpdateUsuario
GO

CREATE PROCEDURE usp_UpdateUsuario
    @id INT,
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios 
    SET nombreCompleto = @nombreCompleto, 
        email = @email, 
        activo = @activo
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DeleteUsuario')
    DROP PROCEDURE usp_DeleteUsuario
GO

CREATE PROCEDURE usp_DeleteUsuario
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_usuarios WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteEmailUsuario')
    DROP PROCEDURE usp_ExisteEmailUsuario
GO

CREATE PROCEDURE usp_ExisteEmailUsuario
    @email NVARCHAR(100),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) 
    FROM tb_usuarios 
    WHERE email = @email
    AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ResetContrasenaUsuario')
    DROP PROCEDURE usp_ResetContrasenaUsuario
GO

CREATE PROCEDURE usp_ResetContrasenaUsuario
    @id INT,
    @contrasenia NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios 
    SET contrasenia = @contrasenia, 
        numeroIntentos = 0 
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
