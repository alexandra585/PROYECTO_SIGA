													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - SECRETARIAS
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
    ORDER BY u.nombreCompleto;
    
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
/*-------------------------------------------------------------------------------------------------*/
