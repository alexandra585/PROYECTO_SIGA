													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - CHATS
/******************************************* CHATS ************************************************/
/******************************************* CHATS ************************************************/
/******************************************* CHATS ************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListarChatDocenteApoderado')
    DROP PROCEDURE usp_ListarChatDocenteApoderado;
GO

CREATE PROCEDURE usp_ListarChatDocenteApoderado
    @apoderadoId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nombreCompleto
    FROM tb_usuarios
    WHERE id = @apoderadoId AND rol = 'Apoderado';

    SELECT
        d.id AS docenteId,
        u.nombreCompleto,
        d.especialidad,
        STUFF((
            SELECT DISTINCT ', ' + c.codigoCurso
            FROM tb_matriculas m2
            INNER JOIN tb_cursoDocente cd2 ON cd2.id = m2.cursoDocenteId
            INNER JOIN tb_cursos c ON c.id = cd2.cursoId
            INNER JOIN tb_apoderadoEstudiante ae2 ON ae2.estudianteId = m2.estudianteId
            WHERE ae2.apoderadoId = @apoderadoId AND ae2.activo = 1 AND cd2.docenteId = d.id
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS cursosRelacionados,
        conv.id AS conversacionId,
        conv.ultimoMensaje,
        conv.ultimoMensajeFecha,
        ISNULL((
            SELECT COUNT(*)
            FROM tb_mensaje msg
            WHERE msg.conversacionId = conv.id AND msg.remitenteId <> @apoderadoId AND msg.leido = 0
        ), 0) AS mensajesNoLeidos
    FROM tb_docentes d
    INNER JOIN tb_usuarios u ON u.id = d.id
    INNER JOIN tb_cursoDocente cd ON cd.docenteId = d.id
    INNER JOIN tb_matriculas m ON m.cursoDocenteId = cd.id
    INNER JOIN tb_apoderadoEstudiante ae ON ae.estudianteId = m.estudianteId
    LEFT JOIN tb_conversacion conv ON conv.apoderadoId = @apoderadoId AND conv.docenteId = d.id
    LEFT JOIN tb_conversacionUsuario cu ON cu.conversacionId = conv.id AND cu.usuarioId = @apoderadoId AND cu.eliminado = 1
    WHERE ae.apoderadoId = @apoderadoId AND ae.activo = 1 AND u.activo = 1 AND u.rol = 'Docente' AND cu.conversacionId IS NULL
    GROUP BY d.id, u.nombreCompleto, d.especialidad, conv.id, conv.ultimoMensaje, conv.ultimoMensajeFecha
    ORDER BY conv.ultimoMensajeFecha DESC, u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListarChatApoderadoDocente')
    DROP PROCEDURE usp_ListarChatApoderadoDocente;
GO

CREATE PROCEDURE usp_ListarChatApoderadoDocente
    @docenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nombreCompleto
    FROM tb_usuarios
    WHERE id = @docenteId AND rol = 'Docente';

    SELECT
        u.id AS apoderadoId,
        u.nombreCompleto,
        STUFF((
            SELECT DISTINCT ', ' + ue.nombreCompleto
            FROM tb_apoderadoEstudiante ae2
            INNER JOIN tb_estudiantes e2 ON e2.id = ae2.estudianteId
            INNER JOIN tb_usuarios ue ON ue.id = e2.id
            INNER JOIN tb_matriculas m2 ON m2.estudianteId = e2.id
            INNER JOIN tb_cursoDocente cd2 ON cd2.id = m2.cursoDocenteId
            WHERE ae2.apoderadoId = u.id AND ae2.activo = 1 AND cd2.docenteId = @docenteId
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS hijosRelacionados,
        conv.id AS conversacionId,
        conv.ultimoMensaje,
        conv.ultimoMensajeFecha,
        ISNULL((
            SELECT COUNT(*)
            FROM tb_mensaje msg
            WHERE msg.conversacionId = conv.id AND msg.remitenteId <> @docenteId AND msg.leido = 0
        ), 0) AS mensajesNoLeidos
    FROM tb_usuarios u
    INNER JOIN tb_apoderadoEstudiante ae ON ae.apoderadoId = u.id AND ae.activo = 1
    INNER JOIN tb_matriculas m ON m.estudianteId = ae.estudianteId
    INNER JOIN tb_cursoDocente cd ON cd.id = m.cursoDocenteId
    LEFT JOIN tb_conversacion conv ON conv.apoderadoId = u.id AND conv.docenteId = @docenteId
    LEFT JOIN tb_conversacionUsuario cu ON cu.conversacionId = conv.id AND cu.usuarioId = @docenteId AND cu.eliminado = 1
    WHERE cd.docenteId = @docenteId AND u.activo = 1 AND u.rol = 'Apoderado' AND cu.conversacionId IS NULL
    GROUP BY u.id, u.nombreCompleto, conv.id, conv.ultimoMensaje, conv.ultimoMensajeFecha
    ORDER BY conv.ultimoMensajeFecha DESC, u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ObtenerCrearChatConversacion')
    DROP PROCEDURE usp_ObtenerCrearChatConversacion;
GO

CREATE PROCEDURE usp_ObtenerCrearChatConversacion
    @apoderadoId INT,
    @docenteId INT,
    @cursoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @conversacionId INT;

    SELECT @conversacionId = id
    FROM tb_conversacion WITH (READCOMMITTEDLOCK)
    WHERE apoderadoId = @apoderadoId
      AND docenteId = @docenteId;

    IF @conversacionId IS NULL
    BEGIN
        BEGIN TRY
            INSERT INTO tb_conversacion (apoderadoId, docenteId, cursoId)
            VALUES (@apoderadoId, @docenteId, @cursoId);
            SET @conversacionId = SCOPE_IDENTITY();

            INSERT INTO tb_conversacionUsuario (conversacionId, usuarioId, eliminado)
            VALUES
                (@conversacionId, @apoderadoId, 0),
                (@conversacionId, @docenteId, 0);
        END TRY
        BEGIN CATCH
            SELECT @conversacionId = id
            FROM tb_conversacion
            WHERE apoderadoId = @apoderadoId
              AND docenteId   = @docenteId;

            IF @conversacionId IS NULL
                THROW;
        END CATCH
    END
    ELSE
    BEGIN
        UPDATE tb_conversacionUsuario
        SET eliminado = 0,
            fechaEliminacion = NULL
        WHERE conversacionId = @conversacionId
          AND usuarioId = @apoderadoId
          AND eliminado = 1;
    END

    SELECT @conversacionId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ObtenerChatConversacion')
    DROP PROCEDURE usp_ObtenerChatConversacion;
GO

CREATE PROCEDURE usp_ObtenerChatConversacion
    @conversacionId INT,
    @usuarioActualId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SELECT
        c.apoderadoId,
        c.docenteId,
        ua.nombreCompleto AS nombreApoderado,
        ud.nombreCompleto AS nombreDocente,
        d.especialidad
    FROM tb_conversacion c
    INNER JOIN tb_usuarios ua ON ua.id = c.apoderadoId
    INNER JOIN tb_usuarios ud ON ud.id = c.docenteId
    LEFT  JOIN tb_docentes d  ON d.id  = c.docenteId
    WHERE c.id = @conversacionId;

    DECLARE @limpiadoHasta DATETIME = NULL;
    SELECT @limpiadoHasta = limpiadoHasta
    FROM tb_conversacionUsuario WITH (NOLOCK)
    WHERE conversacionId = @conversacionId AND usuarioId = @usuarioActualId;

    SELECT
        m.id,
        m.remitenteId,
        u.nombreCompleto AS nombreRemitente,
        m.contenido,
        m.fechaEnvio,
        m.leido
    FROM tb_mensaje m
    INNER JOIN tb_usuarios u ON u.id = m.remitenteId
    WHERE m.conversacionId = @conversacionId AND (@limpiadoHasta IS NULL OR m.fechaEnvio > @limpiadoHasta)
    ORDER BY m.fechaEnvio ASC;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_EnviarChatMensaje')
    DROP PROCEDURE usp_EnviarChatMensaje;
GO

CREATE PROCEDURE usp_EnviarChatMensaje
    @conversacionId INT,
    @remitenteId INT,
    @contenido NVARCHAR(3000)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @nuevoId BIGINT;
    DECLARE @fecha DATETIME = GETDATE();
    INSERT INTO tb_mensaje (conversacionId, remitenteId, contenido, fechaEnvio, leido)
    VALUES (@conversacionId, @remitenteId, @contenido, @fecha, 0);
    SET @nuevoId = SCOPE_IDENTITY();

    UPDATE tb_conversacion
    SET ultimoMensaje = LEFT(@contenido, 200),
        ultimoMensajeFecha = @fecha
    WHERE id = @conversacionId;

    SELECT
        @nuevoId AS id,
        u.nombreCompleto AS nombreRemitente,
        @fecha AS fechaEnvio
    FROM tb_usuarios u
    WHERE u.id = @remitenteId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_MarcarChatComoLeido')
    DROP PROCEDURE usp_MarcarChatComoLeido;
GO

CREATE PROCEDURE usp_MarcarChatComoLeido
    @conversacionId INT,
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb_mensaje
    SET leido = 1
    WHERE conversacionId = @conversacionId AND remitenteId <> @usuarioId AND leido = 0;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_EliminarChat')
    DROP PROCEDURE usp_EliminarChat;
GO

CREATE PROCEDURE usp_EliminarChat
    @conversacionId INT,
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM tb_conversacionUsuario
               WHERE conversacionId = @conversacionId AND usuarioId = @usuarioId)
    BEGIN
        UPDATE tb_conversacionUsuario
        SET eliminado = 1,
            fechaEliminacion = GETDATE()
        WHERE conversacionId = @conversacionId AND usuarioId = @usuarioId;
    END
    ELSE
    BEGIN
        INSERT INTO tb_conversacionUsuario (conversacionId, usuarioId, eliminado, fechaEliminacion)
        VALUES (@conversacionId, @usuarioId, 1, GETDATE());
    END
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_VaciarChat')
    DROP PROCEDURE usp_VaciarChat;
GO

CREATE PROCEDURE usp_VaciarChat
    @conversacionId INT,
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (
        SELECT 1 FROM tb_conversacionUsuario
        WHERE conversacionId = @conversacionId AND usuarioId = @usuarioId
    )
    BEGIN
        INSERT INTO tb_conversacionUsuario (conversacionId, usuarioId, eliminado, limpiadoHasta)
        VALUES (@conversacionId, @usuarioId, 0, GETDATE());
    END
    ELSE
    BEGIN
        UPDATE tb_conversacionUsuario
        SET limpiadoHasta = GETDATE()
        WHERE conversacionId = @conversacionId
          AND usuarioId = @usuarioId;
    END
END
GO
/*-------------------------------------------------------------------------------------------------*/
