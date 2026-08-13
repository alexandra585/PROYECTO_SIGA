													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUD SECRETARIAS
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_Secretarias')
    DROP PROCEDURE usp_Secretarias
GO

CREATE PROCEDURE usp_Secretarias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id,
        u.nombreCompleto,
        u.email,
        u.activo,
        u.fechaRegistro,
        s.cargo,
        s.telefono
    FROM tb_usuarios u
    INNER JOIN tb_secretarias s ON u.id = s.id
    WHERE u.rol = 'Secretaria' AND u.activo = 1
    ORDER BY u.id, u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_SecretariaId')
    DROP PROCEDURE usp_SecretariaId
GO

CREATE PROCEDURE usp_SecretariaId
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
        s.cargo,
        s.telefono
    FROM tb_usuarios u
    INNER JOIN tb_secretarias s ON u.id = s.id
    WHERE u.id = @id AND u.rol = 'Secretaria';
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateUsuarioSecretaria')
    DROP PROCEDURE usp_CreateUsuarioSecretaria
GO

CREATE PROCEDURE usp_CreateUsuarioSecretaria
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @contrasenia NVARCHAR(255),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
    VALUES (@nombreCompleto, @email, @contrasenia, 'Secretaria', @activo);
    SELECT SCOPE_IDENTITY() AS NuevoId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateSecretaria')
    DROP PROCEDURE usp_CreateSecretaria
GO

CREATE PROCEDURE usp_CreateSecretaria
    @id INT,
    @cargo NVARCHAR(100),
    @telefono NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_secretarias (id, cargo, telefono)
    VALUES (@id, @cargo, @telefono);
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateSecretaria')
    DROP PROCEDURE usp_UpdateSecretaria
GO

CREATE PROCEDURE usp_UpdateSecretaria
    @id INT,
    @nombreCompleto NVARCHAR(100),
    @email NVARCHAR(100),
    @activo BIT,
    @cargo NVARCHAR(100),
    @telefono NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_usuarios
    SET nombreCompleto = @nombreCompleto,
        email = @email,
        activo = @activo
    WHERE id = @id;

    UPDATE tb_secretarias
    SET cargo = @cargo,
        telefono = @telefono
    WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DeleteSecretaria')
    DROP PROCEDURE usp_DeleteSecretaria
GO

CREATE PROCEDURE usp_DeleteSecretaria
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_secretarias WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteEmailSecretaria')
    DROP PROCEDURE usp_ExisteEmailSecretaria
GO

CREATE PROCEDURE usp_ExisteEmailSecretaria
    @email NVARCHAR(100),
    @idExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*)
    FROM tb_usuarios
    WHERE email = @email
      AND rol = 'Secretaria'
      AND (@idExcluir IS NULL OR id != @idExcluir);
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_BuscarUsuarioDisponibleSecretaria')
    DROP PROCEDURE usp_BuscarUsuarioDisponibleSecretaria
GO

CREATE PROCEDURE usp_BuscarUsuarioDisponibleSecretaria
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
    LEFT JOIN tb_secretarias s ON u.id = s.id
    WHERE s.id IS NULL
      AND u.activo = 1
      AND u.rol = 'Secretaria'
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
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ActualizarRolUsuarioSecretaria')
    DROP PROCEDURE usp_ActualizarRolUsuarioSecretaria
GO

CREATE PROCEDURE usp_ActualizarRolUsuarioSecretaria
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
