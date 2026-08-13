													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUD DOCENTES
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_Docentes')
    DROP PROCEDURE usp_Docentes
GO

CREATE PROCEDURE usp_Docentes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.activo,
        d.especialidad, 
        d.gradoAcademico
    FROM tb_usuarios u
    INNER JOIN tb_docentes d ON u.id = d.id
    WHERE u.rol = 'Docente' AND u.activo = 1
    ORDER BY u.id, u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DocenteId')
    DROP PROCEDURE usp_DocenteId
GO

CREATE PROCEDURE usp_DocenteId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.activo,
        d.especialidad, 
        d.gradoAcademico
    FROM tb_usuarios u
    INNER JOIN tb_docentes d ON u.id = d.id
    WHERE u.id = @id AND u.rol = 'Docente';
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateUsuarioDocente')
    DROP PROCEDURE usp_CreateUsuarioDocente
GO

CREATE PROCEDURE usp_CreateUsuarioDocente
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @contrasenia NVARCHAR(255),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
    VALUES (@nombreCompleto, @email, @contrasenia, 'Docente', @activo);
    SELECT SCOPE_IDENTITY() AS NuevoId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateDocente')
    DROP PROCEDURE usp_CreateDocente
GO

CREATE PROCEDURE usp_CreateDocente
    @id INT,
    @especialidad NVARCHAR(100),
    @gradoAcademico NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_docentes (id, especialidad, gradoAcademico)
    VALUES (@id, @especialidad, @gradoAcademico);
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateDocente')
    DROP PROCEDURE usp_UpdateDocente
GO

CREATE PROCEDURE usp_UpdateDocente
    @id INT,
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @activo BIT,
    @especialidad NVARCHAR(100),
    @gradoAcademico NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios 
    SET nombreCompleto = @nombreCompleto, 
        email = @email, 
        activo = @activo
    WHERE id = @id;
    
    UPDATE tb_docentes 
    SET especialidad = @especialidad, 
        gradoAcademico = @gradoAcademico
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DeleteDocente')
    DROP PROCEDURE usp_DeleteDocente
GO

CREATE PROCEDURE usp_DeleteDocente
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_docentes WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteEmailDocente')
    DROP PROCEDURE usp_ExisteEmailDocente
GO

CREATE PROCEDURE usp_ExisteEmailDocente
    @email NVARCHAR(100),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*)
    FROM tb_usuarios
    WHERE email = @email
      AND rol = 'Docente'
      AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_BuscarUsuarioDisponibleDocente')
    DROP PROCEDURE usp_BuscarUsuarioDisponibleDocente
GO

CREATE PROCEDURE usp_BuscarUsuarioDisponibleDocente
    @filtro NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.id,
        u.nombreCompleto,
        u.email,
        u.rol,
        u.activo
    FROM tb_usuarios u
    LEFT JOIN tb_docentes d ON u.id = d.id
    WHERE d.id IS NULL
      AND u.activo = 1
      AND u.rol = 'Docente'
      AND (
            @filtro IS NULL
            OR LTRIM(RTRIM(@filtro)) = ''
            OR u.nombreCompleto LIKE '%' + @filtro + '%'
            OR u.email LIKE '%' + @filtro + '%'
          )
    ORDER BY u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ActualizarRolUsuarioDocente')
    DROP PROCEDURE usp_ActualizarRolUsuarioDocente
GO

CREATE PROCEDURE usp_ActualizarRolUsuarioDocente
    @id INT,
    @rol NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios
    SET rol = @rol
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
