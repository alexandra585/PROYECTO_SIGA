													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - FUNCTIONS
/******************************************* LOGIN ************************************************/
/******************************************* LOGIN ************************************************/
/******************************************* LOGIN ************************************************/
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



/******************************************* DIRECTORES ************************************************/
/******************************************* DIRECTORES ************************************************/
/******************************************* DIRECTORES ************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DirectorDashboard')
    DROP PROCEDURE usp_DirectorDashboard
GO

CREATE PROCEDURE usp_DirectorDashboard
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        (SELECT COUNT(*) FROM tb_estudiantes) AS totalEstudiantes,
        (SELECT COUNT(*) FROM tb_docentes) AS totalDocentes,
        (SELECT COUNT(*) FROM tb_cursos) AS totalCursos,
		(SELECT COUNT(*) FROM tb_secretarias) AS totalSecretarias,
		(SELECT COUNT(*) FROM tb_apoderados) AS totalApoderados,
        (SELECT COUNT(*) FROM tb_matriculas WHERE estado = 'Activo') AS totalMatriculasActivas,
        ISNULL((SELECT TOP 1 nombrePeriodo FROM tb_periodoAcademico WHERE esActivo = 1), 'No definido') AS periodoActivo;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_PeriodoAcademico')
    DROP PROCEDURE usp_PeriodoAcademico
GO

CREATE PROCEDURE usp_PeriodoAcademico
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        id,
        nombrePeriodo,
        esActivo
    FROM tb_periodoAcademico
    WHERE esActivo = 1
    ORDER BY nombrePeriodo;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CursoDocente')
    DROP PROCEDURE usp_CursoDocente
GO

CREATE PROCEDURE usp_CursoDocente
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        cd.id, 
        c.nombreCurso, 
        c.codigoCurso, 
        u.nombreCompleto AS NombreDocente, 
        pa.nombrePeriodo
    FROM tb_cursoDocente cd
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_docentes d ON cd.docenteId = d.id
    INNER JOIN tb_usuarios u ON d.id = u.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    WHERE pa.esActivo = 1
    ORDER BY c.nombreCurso;
END
GO



/******************************************* SECRETARIAS ************************************************/
/******************************************* SECRETARIAS ************************************************/
/******************************************* SECRETARIAS ************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_SecretariaDashboard')
    DROP PROCEDURE usp_SecretariaDashboard
GO

CREATE PROCEDURE usp_SecretariaDashboard
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        (SELECT COUNT(*) FROM tb_cursoDocente) AS totalAsignacionesCursoDocente,
        (SELECT COUNT(*) FROM tb_matriculas) AS totalMatriculas,
        (SELECT COUNT(*) FROM tb_apoderadoEstudiante) AS totalAsignacionesApoderadoEstudiante,
        ISNULL((SELECT TOP 1 nombrePeriodo FROM tb_periodoAcademico WHERE esActivo = 1), 'No definido') AS periodoActivo;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_AsignarCursoDocente')
    DROP PROCEDURE usp_AsignarCursoDocente
GO

CREATE PROCEDURE usp_AsignarCursoDocente
    @docenteId INT,
    @cursoId INT,
    @periodoId INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_cursoDocente (cursoId, docenteId, periodoAcademicoId)
    VALUES (@cursoId, @docenteId, @periodoId);
	SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_AsignacionCursoDocenteVM')
    DROP PROCEDURE usp_AsignacionCursoDocenteVM
GO

CREATE PROCEDURE usp_AsignacionCursoDocenteVM
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
    ORDER BY u.nombreCompleto;
    
    SELECT 
        id,
        codigoCurso,
        nombreCurso,
        creditos,
        horasTeoricas,
        horasPracticas
    FROM tb_cursos
    ORDER BY codigoCurso;
    
    SELECT 
        id,
        nombrePeriodo,
        esActivo
    FROM tb_periodoAcademico
    WHERE esActivo = 1
    ORDER BY nombrePeriodo;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListAsignacionCursoDocenteVM')
    DROP PROCEDURE usp_ListAsignacionCursoDocenteVM
GO

CREATE PROCEDURE usp_ListAsignacionCursoDocenteVM
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        cd.id,
        c.codigoCurso,
        c.nombreCurso,
        u.nombreCompleto AS nombreDocente,
        pa.nombrePeriodo,
        (SELECT COUNT(*) FROM tb_matriculas m WHERE m.cursoDocenteId = cd.id) AS cantidadMatriculados
    FROM tb_cursoDocente cd
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_docentes d ON cd.docenteId = d.id
    INNER JOIN tb_usuarios u ON d.id = u.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    ORDER BY c.nombreCurso, pa.nombrePeriodo;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DesasignarCursoDocenteVM')
    DROP PROCEDURE usp_DesasignarCursoDocenteVM
GO

CREATE PROCEDURE usp_DesasignarCursoDocenteVM
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM tb_matriculas WHERE cursoDocenteId = @id)
    BEGIN
        SELECT -1 AS FilasAfectadas;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM tb_evaluaciones WHERE cursoDocenteId = @id)
    BEGIN
        SELECT -2 AS FilasAfectadas;
        RETURN;
    END
    DELETE FROM tb_cursoDocente WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_AsignarCursoEstudiante')
    DROP PROCEDURE usp_AsignarCursoEstudiante
GO

CREATE PROCEDURE usp_AsignarCursoEstudiante
    @alumnoId INT,
    @cursoDocenteId INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tb_matriculas (estudianteId, cursoDocenteId, estado)
    VALUES (@alumnoId, @cursoDocenteId, 'Activo');
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_AsignacionCursoEstudianteVM')
    DROP PROCEDURE usp_AsignacionCursoEstudianteVM
GO

CREATE PROCEDURE usp_AsignacionCursoEstudianteVM
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.activo,
        e.codigoEstudiante, 
        e.nombreCarrera, 
        e.semestreActual
    FROM tb_usuarios u
    INNER JOIN tb_estudiantes e ON u.id = e.id
    WHERE u.rol = 'Estudiante' AND u.activo = 1
    ORDER BY u.id;
    
    SELECT 
        cd.id, 
        c.nombreCurso, 
        c.codigoCurso, 
        u.nombreCompleto AS NombreDocente, 
        pa.nombrePeriodo
    FROM tb_cursoDocente cd
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_docentes d ON cd.docenteId = d.id
    INNER JOIN tb_usuarios u ON d.id = u.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    WHERE pa.esActivo = 1
    ORDER BY c.nombreCurso;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListAsignacionCursoEstudianteVM')
    DROP PROCEDURE usp_ListAsignacionCursoEstudianteVM
GO

CREATE PROCEDURE usp_ListAsignacionCursoEstudianteVM
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        m.id,
        e.codigoEstudiante,
        uEst.nombreCompleto AS nombreEstudiante,
        c.codigoCurso,
        c.nombreCurso,
        uDoc.nombreCompleto AS nombreDocente,
        pa.nombrePeriodo,
        m.estado,
        m.fechaMatricula,
        (SELECT COUNT(*) FROM tb_notas n WHERE n.matriculaId = m.id) AS cantidadNotas,
        (SELECT COUNT(*) FROM tb_asistencias a WHERE a.matriculaId = m.id) AS cantidadAsistencias
    FROM tb_matriculas m
    INNER JOIN tb_estudiantes e ON m.estudianteId = e.id
    INNER JOIN tb_usuarios uEst ON e.id = uEst.id
    INNER JOIN tb_cursoDocente cd ON m.cursoDocenteId = cd.id
    INNER JOIN tb_cursos c ON cd.cursoId = c.id
    INNER JOIN tb_docentes d ON cd.docenteId = d.id
    INNER JOIN tb_usuarios uDoc ON d.id = uDoc.id
    INNER JOIN tb_periodoAcademico pa ON cd.periodoAcademicoId = pa.id
    ORDER BY e.codigoEstudiante, uEst.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DesasignarCursoEstudianteVM')
    DROP PROCEDURE usp_DesasignarCursoEstudianteVM
GO

CREATE PROCEDURE usp_DesasignarCursoEstudianteVM
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM tb_notas WHERE matriculaId = @id)
    BEGIN
        SELECT -1 AS FilasAfectadas;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM tb_asistencias WHERE matriculaId = @id)
    BEGIN
        SELECT -2 AS FilasAfectadas;
        RETURN;
    END
    DELETE FROM tb_matriculas WHERE id = @id;
    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_AsignarApoderadoEstudiante')
    DROP PROCEDURE usp_AsignarApoderadoEstudiante
GO

CREATE PROCEDURE usp_AsignarApoderadoEstudiante
    @apoderadoId INT,
    @estudianteId INT,
    @parentesco NVARCHAR(50),
    @parentescoDetalle NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM tb_usuarios WHERE id = @apoderadoId AND rol = 'Apoderado' AND activo = 1)
    BEGIN
        SELECT -1 AS Resultado;
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM tb_estudiantes e
        INNER JOIN tb_usuarios u ON u.id = e.id
        WHERE e.id = @estudianteId AND u.activo = 1 AND u.rol = 'Estudiante'
    )
    BEGIN
        SELECT -2 AS Resultado;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM tb_apoderadoEstudiante
        WHERE apoderadoId = @apoderadoId AND estudianteId = @estudianteId AND activo = 1
    )
    BEGIN
        SELECT -3 AS Resultado;
        RETURN;
    END

    IF @parentesco <> 'Otro'
        SET @parentescoDetalle = NULL;
    INSERT INTO tb_apoderadoEstudiante (apoderadoId, estudianteId, parentesco, parentescoDetalle, activo)
    VALUES (@apoderadoId, @estudianteId, @parentesco, @parentescoDetalle, 1);
    SELECT @@ROWCOUNT AS Resultado;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListApoderadosActivos')
    DROP PROCEDURE usp_ListApoderadosActivos
GO

CREATE PROCEDURE usp_ListApoderadosActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, nombreCompleto, email
    FROM tb_usuarios
    WHERE rol = 'Apoderado' AND activo = 1
    ORDER BY nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ListAsignacionApoderadoEstudianteVM')
    DROP PROCEDURE usp_ListAsignacionApoderadoEstudianteVM
GO

CREATE PROCEDURE usp_ListAsignacionApoderadoEstudianteVM
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ae.id,
        ae.apoderadoId,
        ua.nombreCompleto AS NombreApoderado,
        ua.email AS EmailApoderado,
        ae.estudianteId,
        ue.nombreCompleto AS NombreEstudiante,
        e.codigoEstudiante,
        ae.parentesco,
        ae.parentescoDetalle,
        ae.fechaRegistro,
        ae.activo
    FROM tb_apoderadoEstudiante ae
    INNER JOIN tb_usuarios ua ON ua.id = ae.apoderadoId
    INNER JOIN tb_estudiantes e ON e.id = ae.estudianteId
    INNER JOIN tb_usuarios ue ON ue.id = e.id
    WHERE ae.activo = 1
      AND ua.activo = 1
      AND ue.activo = 1
    ORDER BY ua.nombreCompleto, ue.nombreCompleto;
END
GO
/*-------------------------------------------------------------------------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_DesasignarApoderadoEstudianteVM')
    DROP PROCEDURE usp_DesasignarApoderadoEstudianteVM
GO

CREATE PROCEDURE usp_DesasignarApoderadoEstudianteVM
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tb_apoderadoEstudiante
    WHERE id = @id;
    SELECT @@ROWCOUNT AS Resultado;
END
GO



/******************************************* DOCENTES ************************************************/
/******************************************* DOCENTES ************************************************/
/******************************************* DOCENTES ************************************************/
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



/******************************************* ESTUDIANTES ************************************************/
/******************************************* ESTUDIANTES ************************************************/
/******************************************* ESTUDIANTES ************************************************/
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



/******************************************* APODERADOS ************************************************/
/******************************************* APODERADOS ************************************************/
/******************************************* APODERADOS ************************************************/
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



/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/