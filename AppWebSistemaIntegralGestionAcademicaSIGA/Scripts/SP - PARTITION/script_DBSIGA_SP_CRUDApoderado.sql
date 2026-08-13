													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUD APODERADOS
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_Apoderados')
    DROP PROCEDURE usp_Apoderados
GO

CREATE PROCEDURE usp_Apoderados
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id,
        u.nombreCompleto,
        u.email,
        u.activo,
        u.fechaRegistro,
        ISNULL(NULLIF(LTRIM(RTRIM(a.telefono)), ''), 'Sin teléfono registrado') AS telefono,
        a.dni,
        ISNULL(NULLIF(LTRIM(RTRIM(a.direccion)), ''), 'Sin dirección registrada') AS direccion,
        ISNULL(COUNT(ae.id), 0) AS cantidadHijos
    FROM tb_usuarios u
    INNER JOIN tb_apoderados a ON a.id = u.id
    LEFT JOIN tb_apoderadoEstudiante ae 
        ON ae.apoderadoId = u.id AND ae.activo = 1
    WHERE u.rol = 'Apoderado'
    GROUP BY 
        u.id, u.nombreCompleto, u.email, u.activo, u.fechaRegistro,
        a.telefono, a.dni, a.direccion
    ORDER BY u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ApoderadoId')
    DROP PROCEDURE usp_ApoderadoId
GO

CREATE PROCEDURE usp_ApoderadoId
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
        a.telefono,
        a.dni,
        a.direccion
    FROM tb_usuarios u
    INNER JOIN tb_apoderados a ON a.id = u.id
    WHERE u.id = @id AND u.rol = 'Apoderado';
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateUsuarioApoderado')
    DROP PROCEDURE usp_CreateUsuarioApoderado
GO

CREATE PROCEDURE usp_CreateUsuarioApoderado
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @contrasenia NVARCHAR(255),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
    VALUES (@nombreCompleto, @email, @contrasenia, 'Apoderado', @activo);
    SELECT SCOPE_IDENTITY() AS NuevoId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateApoderado')
    DROP PROCEDURE usp_CreateApoderado
GO

CREATE PROCEDURE usp_CreateApoderado
    @id INT,
    @telefono NVARCHAR(20),
    @dni NVARCHAR(15),
    @direccion NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_apoderados (id, telefono, dni, direccion)
    VALUES (@id, @telefono, @dni, @direccion);
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateApoderado')
    DROP PROCEDURE usp_UpdateApoderado
GO

CREATE PROCEDURE usp_UpdateApoderado
    @id INT,
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @activo BIT,
    @telefono NVARCHAR(20),
    @dni NVARCHAR(15),
    @direccion NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios
    SET nombreCompleto = @nombreCompleto,
        email = @email,
        activo = @activo
    WHERE id = @id;

    UPDATE tb_apoderados
    SET telefono = @telefono,
        dni = @dni,
        direccion = @direccion
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DeleteApoderado')
    DROP PROCEDURE usp_DeleteApoderado
GO

CREATE PROCEDURE usp_DeleteApoderado
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_apoderados WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteEmailApoderado')
    DROP PROCEDURE usp_ExisteEmailApoderado
GO

CREATE PROCEDURE usp_ExisteEmailApoderado
    @email NVARCHAR(100),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*)
    FROM tb_usuarios
    WHERE email = @email
      AND rol = 'Apoderado'
      AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteDniApoderado')
    DROP PROCEDURE usp_ExisteDniApoderado
GO

CREATE PROCEDURE usp_ExisteDniApoderado
    @dni NVARCHAR(15),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*)
    FROM tb_apoderados
    WHERE dni = @dni
      AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_BuscarUsuarioDisponibleApoderado')
    DROP PROCEDURE usp_BuscarUsuarioDisponibleApoderado
GO

CREATE PROCEDURE usp_BuscarUsuarioDisponibleApoderado
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
    LEFT JOIN tb_apoderados a ON u.id = a.id
    WHERE a.id IS NULL
      AND u.activo = 1
      AND u.rol = 'Apoderado'
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
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ActualizarRolUsuarioApoderado')
    DROP PROCEDURE usp_ActualizarRolUsuarioApoderado
GO

CREATE PROCEDURE usp_ActualizarRolUsuarioApoderado
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
