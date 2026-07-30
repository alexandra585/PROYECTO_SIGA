													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - DOCENTES
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DocenteDashboard')
    DROP PROCEDURE usp_DocenteDashboard
GO

CREATE PROCEDURE usp_DocenteDashboard
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.nombreCompleto, 
        d.especialidad, 
        d.gradoAcademico
    FROM tb_usuarios u
    INNER JOIN tb_docentes d ON u.id = d.id
    WHERE u.id = @usuarioId;
    
    SELECT 
        cd.id, 
        c.nombreCurso, 
        c.codigoCurso, 
        pa.nombrePeriodo
    FROM tb_cursoDocente cd
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    WHERE cd.docenteId = @usuarioId AND pa.esActivo = 1;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CursosAsignadosDocente')
    DROP PROCEDURE usp_CursosAsignadosDocente
GO

CREATE PROCEDURE usp_CursosAsignadosDocente
    @docenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        cd.id AS CursoDocenteId, 
        c.id AS CursoId,
        c.codigoCurso, 
        c.nombreCurso,
        c.creditos,
        pa.nombrePeriodo,
        pa.id AS PeriodoId
    FROM tb_cursoDocente cd
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    WHERE cd.docenteId = @docenteId AND pa.esActivo = 1
    ORDER BY c.nombreCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CursosEstudiantesDocente')
    DROP PROCEDURE usp_CursosEstudiantesDocente
GO

CREATE PROCEDURE usp_CursosEstudiantesDocente
    @cursoDocenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        m.id AS MatriculaId,
        e.id AS EstudianteId,
        u.nombreCompleto,
        e.codigoEstudiante,
        e.nombreCarrera,
        e.semestreActual,
        m.estado AS EstadoMatricula,
        ISNULL((
            SELECT AVG(n.nota) 
            FROM tb_notas n 
            WHERE n.matriculaId = m.id
        ), 0) AS PromedioActual
    FROM tb_matriculas m
    INNER JOIN tb_estudiantes e ON m.estudianteId = e.id
    INNER JOIN tb_usuarios u ON e.id = u.id
    WHERE m.cursoDocenteId = @cursoDocenteId AND m.estado = 'Activo'
    ORDER BY u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CursosEvaluacionesDocente')
    DROP PROCEDURE usp_CursosEvaluacionesDocente
GO

CREATE PROCEDURE usp_CursosEvaluacionesDocente
    @cursoDocenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        e.id AS EvaluacionId,
        te.nombre AS NombreEvaluacion,
        te.nombre AS TipoEvaluacion,
        e.fechaEvaluacion,
        e.notaPorcentual
    FROM tb_evaluaciones e
    INNER JOIN tb_tipoEvaluacion te ON e.tipoEvaluacionId = te.id
    WHERE e.cursoDocenteId = @cursoDocenteId
    ORDER BY e.fechaEvaluacion;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_RegistrarNotas')
    DROP PROCEDURE usp_RegistrarNotas
GO

CREATE PROCEDURE usp_RegistrarNotas
    @matriculaId INT,
    @evaluacionId INT,
    @nota DECIMAL(4,2),
    @docenteId INT,
    @observacion NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM tb_notas WHERE matriculaId = @matriculaId AND evaluacionId = @evaluacionId)
    BEGIN
        UPDATE tb_notas 
        SET nota = @nota, 
            observacion = @observacion,
            docenteRegistroId = @docenteId,
            fechaRegistro = GETDATE()
        WHERE matriculaId = @matriculaId AND evaluacionId = @evaluacionId;
        SELECT @@ROWCOUNT AS FilasAfectadas;
    END
    ELSE
    BEGIN
        INSERT INTO tb_notas (matriculaId, evaluacionId, nota, docenteRegistroId, observacion)
        VALUES (@matriculaId, @evaluacionId, @nota, @docenteId, @observacion);
        SELECT @@ROWCOUNT AS FilasAfectadas;
    END
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_RegistrarAsistencias')
    DROP PROCEDURE usp_RegistrarAsistencias
GO

CREATE PROCEDURE usp_RegistrarAsistencias
    @matriculaId INT,
    @estado NVARCHAR(20),
    @docenteId INT,
    @observacion NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM tb_asistencias WHERE matriculaId = @matriculaId AND CAST(fecha AS DATE) = CAST(GETDATE() AS DATE))
    BEGIN
        UPDATE tb_asistencias 
        SET estado = @estado, 
            observacion = @observacion,
            docenteRegistroId = @docenteId,
            horaRegistro = GETDATE()
        WHERE matriculaId = @matriculaId AND CAST(fecha AS DATE) = CAST(GETDATE() AS DATE);
        SELECT @@ROWCOUNT AS FilasAfectadas;
    END
    ELSE
    BEGIN
        INSERT INTO tb_asistencias (matriculaId, fecha, estado, docenteRegistroId, observacion)
        VALUES (@matriculaId, GETDATE(), @estado, @docenteId, @observacion);
        SELECT @@ROWCOUNT AS FilasAfectadas;
    END
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ObtenerNotasPorMatricula')
    DROP PROCEDURE usp_ObtenerNotasPorMatricula
GO

CREATE PROCEDURE usp_ObtenerNotasPorMatricula
    @matriculaId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        n.id AS NotaId,
        n.evaluacionId,
        te.nombre AS NombreEvaluacion,
        n.nota,
        n.observacion,
        n.fechaRegistro
    FROM tb_notas n
    INNER JOIN tb_evaluaciones e ON n.evaluacionId = e.id
    INNER JOIN tb_tipoEvaluacion te ON e.tipoEvaluacionId = te.id
    WHERE n.matriculaId = @matriculaId
    ORDER BY e.fechaEvaluacion;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ObtenerNotasExistentes')
    DROP PROCEDURE usp_ObtenerNotasExistentes
GO

CREATE PROCEDURE usp_ObtenerNotasExistentes
    @cursoDocenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        n.matriculaId, 
        n.evaluacionId, 
        n.nota, 
        n.observacion
    FROM tb_notas n
    INNER JOIN tb_matriculas m ON n.matriculaId = m.id
    WHERE m.cursoDocenteId = @cursoDocenteId;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ObtenerAsistenciasPorCurso')
    DROP PROCEDURE usp_ObtenerAsistenciasPorCurso
GO

CREATE PROCEDURE usp_ObtenerAsistenciasPorCurso
    @cursoDocenteId INT,
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        m.id AS MatriculaId,
        e.id AS EstudianteId,
        u.nombreCompleto,
        e.codigoEstudiante,
        ISNULL(a.estado, 'No registrado') AS EstadoAsistencia,
        a.observacion,
        a.horaRegistro
    FROM tb_matriculas m
    INNER JOIN tb_estudiantes e ON m.estudianteId = e.id
    INNER JOIN tb_usuarios u ON e.id = u.id
    LEFT JOIN tb_asistencias a ON a.matriculaId = m.id AND CAST(a.fecha AS DATE) = @fecha
    WHERE m.cursoDocenteId = @cursoDocenteId AND m.estado = 'Activo'
    ORDER BY u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ObtenerReporteCurso')
    DROP PROCEDURE usp_ObtenerReporteCurso
GO

CREATE PROCEDURE usp_ObtenerReporteCurso
    @cursoDocenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.nombreCurso, 
        c.codigoCurso, 
        c.creditos,
        u.nombreCompleto AS NombreDocente,
        pa.nombrePeriodo
    FROM tb_cursoDocente cd
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_docentes d ON cd.docenteId = d.id
    INNER JOIN tb_usuarios u ON d.id = u.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    WHERE cd.id = @cursoDocenteId;
    
    SELECT 
        m.id AS MatriculaId,
        e.id AS EstudianteId,
        u.nombreCompleto,
        e.codigoEstudiante,
        e.nombreCarrera,
        e.semestreActual,
        m.estado AS EstadoMatricula,
        ISNULL((
            SELECT AVG(n.nota) 
            FROM tb_notas n 
            WHERE n.matriculaId = m.id
        ), 0) AS PromedioActual
    FROM tb_matriculas m
    INNER JOIN tb_estudiantes e ON m.estudianteId = e.id
    INNER JOIN tb_usuarios u ON e.id = u.id
    WHERE m.cursoDocenteId = @cursoDocenteId AND m.estado = 'Activo'
    ORDER BY u.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
