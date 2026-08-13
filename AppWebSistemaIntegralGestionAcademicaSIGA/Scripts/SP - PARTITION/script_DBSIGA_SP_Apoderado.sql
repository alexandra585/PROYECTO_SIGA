													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - APODERADOS
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ApoderadoDashboard')
    DROP PROCEDURE usp_ApoderadoDashboard
GO

CREATE PROCEDURE usp_ApoderadoDashboard
    @apoderadoId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nombreCompleto
    FROM tb_usuarios
    WHERE id = @apoderadoId AND rol = 'Apoderado';
    
    SELECT TOP 1 nombrePeriodo
    FROM tb_periodoAcademico
    WHERE esActivo = 1
    ORDER BY id DESC;
    
    SELECT
        e.id AS EstudianteId,
        u.nombreCompleto AS NombreCompleto,
        e.codigoEstudiante,
        ae.parentesco
    FROM tb_apoderadoEstudiante ae
    INNER JOIN tb_estudiantes e ON ae.estudianteId = e.id
    INNER JOIN tb_usuarios u ON e.id = u.id
    WHERE ae.apoderadoId = @apoderadoId AND ae.activo = 1
    ORDER BY e.codigoEstudiante;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListHijos')
    DROP PROCEDURE usp_ListHijos
GO

CREATE PROCEDURE usp_ListHijos
    @apoderadoId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.id AS EstudianteId,
        u.nombreCompleto,
        e.codigoEstudiante,
        ae.parentesco
    FROM tb_apoderadoEstudiante ae
    INNER JOIN tb_estudiantes e ON e.id = ae.estudianteId
    INNER JOIN tb_usuarios u ON u.id = e.id
    WHERE ae.apoderadoId = @apoderadoId
      AND ae.activo = 1
      AND u.activo = 1
    ORDER BY u.id;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListPeriodos')
    DROP PROCEDURE usp_ListPeriodos
GO

CREATE PROCEDURE usp_ListPeriodos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        id, 
        nombrePeriodo, 
        esActivo
    FROM tb_periodoAcademico
    ORDER BY id;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_LibretaNotas')
    DROP PROCEDURE usp_LibretaNotas
GO

CREATE PROCEDURE usp_LibretaNotas
    @estudianteId INT,
    @periodoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        pa.id AS periodoId,
        pa.nombrePeriodo,
        pa.esActivo,
        c.codigoCurso,
        c.nombreCurso,
        uDoc.nombreCompleto AS nombreDocente,
        ISNULL(te.nombre, '') AS tipoEvaluacion,
        n.nota,
        ev.notaPorcentual  AS peso,
        ev.fechaEvaluacion
    FROM tb_matriculas m
    INNER JOIN tb_cursoDocente cd ON cd.id = m.cursoDocenteId
    INNER JOIN tb_cursos c ON c.id = cd.cursoId
    INNER JOIN tb_periodoAcademico pa ON pa.id = cd.periodoAcademicoId
    INNER JOIN tb_docentes d ON d.id = cd.docenteId
    INNER JOIN tb_usuarios uDoc ON uDoc.id = d.id
    LEFT JOIN tb_notas n ON n.matriculaId = m.id
    LEFT JOIN tb_evaluaciones ev ON ev.id = n.evaluacionId
    LEFT JOIN tb_tipoEvaluacion te ON te.id = ev.tipoEvaluacionId
    WHERE m.estudianteId = @estudianteId
      AND (@periodoId IS NULL OR pa.id = @periodoId)
    ORDER BY pa.esActivo DESC, pa.id DESC, c.codigoCurso, ev.fechaEvaluacion;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ValidarEstudiante')
    DROP PROCEDURE usp_ValidarEstudiante
GO

CREATE PROCEDURE usp_ValidarEstudiante
    @apoderadoId INT,
    @estudianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.nombreCompleto,
        e.codigoEstudiante,
        ae.parentesco
    FROM tb_apoderadoEstudiante ae
    INNER JOIN tb_estudiantes e ON e.id = ae.estudianteId
    INNER JOIN tb_usuarios u ON u.id = e.id
    WHERE ae.apoderadoId = @apoderadoId
      AND ae.estudianteId = @estudianteId
      AND ae.activo = 1;
END
GO
/*-------------------------------------------------------------------------------------------------*/
