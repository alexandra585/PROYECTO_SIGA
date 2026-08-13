													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - LOGIN
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ValidarUsuario')
    DROP PROCEDURE usp_ValidarUsuario
GO

CREATE PROCEDURE usp_ValidarUsuario
    @email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        id, 
        nombreCompleto, 
        email, 
        contrasenia, 
        rol, 
        activo, 
        numeroIntentos
    FROM tb_usuarios
    WHERE email = @email;
END
GO
