													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - ESTUDIANTES
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_EstudianteDashboard')
    DROP PROCEDURE usp_EstudianteDashboard
GO

CREATE PROCEDURE usp_EstudianteDashboard
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.nombreCompleto, 
        e.codigoEstudiante, 
        e.nombreCarrera, 
        e.semestreActual
    FROM tb_usuarios u
    INNER JOIN tb_estudiantes e ON u.id = e.id
    WHERE u.id = @usuarioId;
    
    SELECT 
        m.id AS MatriculaId, 
        m.estado, 
        m.cursoDocenteId, 
        c.nombreCurso, 
        c.codigoCurso,
        ISNULL((
            SELECT AVG(n.nota) 
            FROM tb_notas n 
            WHERE n.matriculaId = m.id
        ), 0) AS NotaFinal
    FROM tb_matriculas m
    INNER JOIN tb_cursoDocente cd ON m.cursoDocenteId = cd.id
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    WHERE m.estudianteId = @usuarioId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_MisCursos')
    DROP PROCEDURE usp_MisCursos
GO

CREATE PROCEDURE usp_MisCursos
    @estudianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        m.id AS MatriculaId,
        c.id AS CursoId,
        c.codigoCurso,
        c.nombreCurso,
        c.creditos,
        cd.id AS CursoDocenteId,
        u.nombreCompleto AS NombreDocente,
        m.estado AS EstadoMatricula,
        ISNULL((
            SELECT AVG(n.nota) 
            FROM tb_notas n 
            WHERE n.matriculaId = m.id
        ), 0) AS PromedioActual
    FROM tb_matriculas m
    INNER JOIN tb_cursoDocente cd ON m.cursoDocenteId = cd.id
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_docentes d ON cd.docenteId = d.id
    INNER JOIN tb_usuarios u ON d.id = u.id
    WHERE m.estudianteId = @estudianteId AND m.estado = 'Activo'
    ORDER BY c.nombreCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_MisNotasCursos')
    DROP PROCEDURE usp_MisNotasCursos
GO

CREATE PROCEDURE usp_MisNotasCursos
    @matriculaId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        e.id AS EvaluacionId,
        te.nombre AS TipoEvaluacion,
        e.fechaEvaluacion,
        e.notaPorcentual,
        ISNULL(n.nota, 0) AS NotaObtenida,
        n.observacion,
        n.fechaRegistro
    FROM tb_evaluaciones e
    INNER JOIN tb_tipoEvaluacion te ON e.tipoEvaluacionId = te.id
    LEFT JOIN tb_notas n ON n.evaluacionId = e.id AND n.matriculaId = @matriculaId
    WHERE e.cursoDocenteId = (
        SELECT cursoDocenteId FROM tb_matriculas WHERE id = @matriculaId
    )
    ORDER BY e.fechaEvaluacion;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ResumenNotas')
    DROP PROCEDURE usp_ResumenNotas
GO

CREATE PROCEDURE usp_ResumenNotas
    @estudianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.id AS CursoId,
        c.codigoCurso,
        c.nombreCurso,
        c.creditos,
        ISNULL((
            SELECT AVG(n.nota) 
            FROM tb_notas n 
            WHERE n.matriculaId = m.id
        ), 0) AS PromedioFinal,
        CASE 
            WHEN ISNULL((
                SELECT AVG(n.nota) 
                FROM tb_notas n 
                WHERE n.matriculaId = m.id
            ), 0) >= 12.5 THEN 'Aprobado'
            WHEN ISNULL((
                SELECT AVG(n.nota) 
                FROM tb_notas n 
                WHERE n.matriculaId = m.id
            ), 0) > 0 THEN 'Desaprobado'
            ELSE 'Sin notas'
        END AS Estado
    FROM tb_matriculas m
    INNER JOIN tb_cursoDocente cd ON m.cursoDocenteId = cd.id
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    WHERE m.estudianteId = @estudianteId AND m.estado = 'Activo'
    ORDER BY c.nombreCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_MisAsistencias')
    DROP PROCEDURE usp_MisAsistencias
GO

CREATE PROCEDURE usp_MisAsistencias
    @estudianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.nombreCurso,
        c.codigoCurso,
        a.fecha,
        a.estado,
        a.observacion,
        a.horaRegistro
    FROM tb_asistencias a
    INNER JOIN tb_matriculas m ON a.matriculaId = m.id
    INNER JOIN tb_cursoDocente cd ON m.cursoDocenteId = cd.id
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    WHERE m.estudianteId = @estudianteId AND m.estado = 'Activo'
    ORDER BY a.fecha DESC, c.nombreCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ReporteAcademico')
    DROP PROCEDURE usp_ReporteAcademico
GO

CREATE PROCEDURE usp_ReporteAcademico
    @estudianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.nombreCompleto, 
        u.email, 
        e.codigoEstudiante, 
        e.nombreCarrera, 
        e.semestreActual
    FROM tb_usuarios u
    INNER JOIN tb_estudiantes e ON u.id = e.id
    WHERE u.id = @estudianteId;
    
    SELECT 
        c.id AS CursoId,
        c.codigoCurso,
        c.nombreCurso,
        c.creditos,
        ISNULL((
            SELECT AVG(n.nota) 
            FROM tb_notas n 
            WHERE n.matriculaId = m.id
        ), 0) AS PromedioFinal,
        CASE 
            WHEN ISNULL((
                SELECT AVG(n.nota) 
                FROM tb_notas n 
                WHERE n.matriculaId = m.id
            ), 0) >= 12.5 THEN 'Aprobado'
            WHEN ISNULL((
                SELECT AVG(n.nota) 
                FROM tb_notas n 
                WHERE n.matriculaId = m.id
            ), 0) > 0 THEN 'Desaprobado'
            ELSE 'Sin notas'
        END AS Estado
    FROM tb_matriculas m
    INNER JOIN tb_cursoDocente cd ON m.cursoDocenteId = cd.id
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    WHERE m.estudianteId = @estudianteId AND m.estado = 'Activo'
    ORDER BY c.nombreCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CalcularPromedioGeneralEstudiante')
    DROP PROCEDURE usp_CalcularPromedioGeneralEstudiante
GO

CREATE PROCEDURE usp_CalcularPromedioGeneralEstudiante
    @estudianteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL(AVG(promedioCurso), 0) AS PromedioGeneral
    FROM (
        SELECT m.id, AVG(n.nota) as promedioCurso
        FROM tb_matriculas m
        INNER JOIN tb_notas n ON m.id = n.matriculaId
        WHERE m.estudianteId = @estudianteId
        GROUP BY m.id
        HAVING AVG(n.nota) > 0
    ) AS CursosConNota;
END
GO
/*-------------------------------------------------------------------------------------------------*/
