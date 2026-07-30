													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CRUDS
/******************************************* CRUD USUARIOS ************************************************/
/******************************************* CRUD USUARIOS ************************************************/
/******************************************* CRUD USUARIOS ************************************************/
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



/******************************************* CRUD SECRETARIAS ************************************************/
/******************************************* CRUD SECRETARIAS ************************************************/
/******************************************* CRUD SECRETARIAS ************************************************/
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



/******************************************* CRUD DOCENTES ************************************************/
/******************************************* CRUD DOCENTES ************************************************/
/******************************************* CRUD DOCENTES ************************************************/
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
/*-------------------------------------------------------------------------------------------------*/
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



/******************************************* CRUD ESTUDIANTES ************************************************/
/******************************************* CRUD ESTUDIANTES ************************************************/
/******************************************* CRUD ESTUDIANTES ************************************************/
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



/******************************************* CRUD APODERADOS ************************************************/
/******************************************* CRUD APODERADOS ************************************************/
/******************************************* CRUD APODERADOS ************************************************/
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



/******************************************* CRUD CURSOS ************************************************/
/******************************************* CRUD CURSOS ************************************************/
/******************************************* CRUD CURSOS ************************************************/
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
