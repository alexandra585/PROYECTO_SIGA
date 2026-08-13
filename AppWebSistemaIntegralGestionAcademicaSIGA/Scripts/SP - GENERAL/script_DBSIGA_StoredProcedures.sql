													
													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS
/******************************************* LOGIN ************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ValidarUsuario')
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
/***************************************** DIRECTORES **************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DirectorDashboard')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PeriodoAcademico')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CursoDocente')
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
/***************************************** SECRETARÍAS **************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_SecretariaDashboard')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateUsuarioSecretaria')
    DROP PROCEDURE usp_CreateUsuarioSecretaria
GO

CREATE PROCEDURE usp_CreateUsuarioSecretaria
    @nombreCompleto NVARCHAR(100),
    @email          NVARCHAR(100),
    @contrasenia    NVARCHAR(255),
    @activo         BIT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
    VALUES (@nombreCompleto, @email, @contrasenia, 'Secretaria', @activo);

    SELECT SCOPE_IDENTITY() AS NuevoId;
END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AsignarCursoDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AsignarCursoEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AsignacionCursoDocenteVM')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AsignacionCursoEstudianteVM')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ListAsignacionCursoDocenteVM')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DesasignarCursoDocenteVM')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ListAsignacionCursoEstudianteVM')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DesasignarCursoEstudianteVM')
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
/***************************************** DOCENTES **************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DocenteDashboard')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateUsuarioDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CursosAsignadosDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CursosEstudiantesDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CursosEvaluacionesDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerNotasPorMatricula')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerNotasExistentes')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarNotas')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarAsistencias')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerAsistenciasPorCurso')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerReporteCurso')
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
/***************************************** CRUD **************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Docentes')
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
/*******************************************************************************************/
CREATE OR ALTER PROCEDURE usp_DocentesPaginado
    @Pagina INT = 1,
    @TamanioPagina INT = 10,
    @Nombre NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Especialidad NVARCHAR(100) = NULL,
    @GradoAcademico NVARCHAR(50) = NULL,
    @Activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- VALIDAR PAGINACIÓN
    -- ==========================================
    IF @Pagina < 1
        SET @Pagina = 1;

    IF @TamanioPagina < 1
        SET @TamanioPagina = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Pagina - 1) * @TamanioPagina;


    -- ==========================================
    -- LISTADO PAGINADO
    -- ==========================================
    SELECT 
        u.id, 
        u.nombreCompleto, 
        u.email, 
        u.activo,
        d.especialidad, 
        d.gradoAcademico

    FROM tb_usuarios u

    INNER JOIN tb_docentes d 
        ON u.id = d.id

    WHERE 
        u.rol = 'Docente'

        -- Filtro por nombre
        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        -- Filtro por email
        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        -- Filtro por especialidad
        AND (
            @Especialidad IS NULL
            OR d.especialidad LIKE '%' + @Especialidad + '%'
        )

        -- Filtro por grado académico
        AND (
            @GradoAcademico IS NULL
            OR d.gradoAcademico LIKE '%' + @GradoAcademico + '%'
        )

        -- Filtro por estado
        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        )

    ORDER BY 
        u.id,
        u.nombreCompleto

    OFFSET @Offset ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;


    -- ==========================================
    -- TOTAL DE REGISTROS
    -- ==========================================
    SELECT 
        COUNT(*) AS totalRegistros

    FROM tb_usuarios u

    INNER JOIN tb_docentes d 
        ON u.id = d.id

    WHERE 
        u.rol = 'Docente'

        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        AND (
            @Especialidad IS NULL
            OR d.especialidad LIKE '%' + @Especialidad + '%'
        )

        AND (
            @GradoAcademico IS NULL
            OR d.gradoAcademico LIKE '%' + @GradoAcademico + '%'
        )

        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        );
END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DocenteId')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateDocente')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteDocente')
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
/*******************************************************************************************/
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
/*************************************** ESTUDIANTES ****************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateUsuarioEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExisteCodigoEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExisteEmailEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EstudianteDashboard')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CalcularPromedioGeneralEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_MisCursos')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_MisNotasCursos')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ResumenNotas')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_MisAsistencias')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ReporteAcademico')
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
/****************************************** CRUD *************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Estudiantes')
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
/*******************************************************************************************/
CREATE OR ALTER PROCEDURE usp_EstudiantesPaginado
    @Pagina INT = 1,
    @TamanioPagina INT = 10,
    @Nombre NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @CodigoEstudiante NVARCHAR(20) = NULL,
    @NombreCarrera NVARCHAR(100) = NULL,
    @SemestreActual TINYINT = NULL,
    @Activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- VALIDAR PAGINACIÓN
    -- ==========================================
    IF @Pagina < 1
        SET @Pagina = 1;

    IF @TamanioPagina < 1
        SET @TamanioPagina = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Pagina - 1) * @TamanioPagina;


    -- ==========================================
    -- LISTADO PAGINADO
    -- ==========================================
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

    INNER JOIN tb_estudiantes e 
        ON u.id = e.id

    WHERE 
        u.rol = 'Estudiante'

        -- Filtro por nombre
        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        -- Filtro por email
        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        -- Filtro por código de estudiante
        AND (
            @CodigoEstudiante IS NULL
            OR e.codigoEstudiante LIKE '%' + @CodigoEstudiante + '%'
        )

        -- Filtro por carrera
        AND (
            @NombreCarrera IS NULL
            OR e.nombreCarrera LIKE '%' + @NombreCarrera + '%'
        )

        -- Filtro por semestre
        AND (
            @SemestreActual IS NULL
            OR e.semestreActual = @SemestreActual
        )

        -- Filtro por estado
        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        )

    ORDER BY 
        u.id,
        u.nombreCompleto

    OFFSET @Offset ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;


    -- ==========================================
    -- TOTAL DE REGISTROS
    -- ==========================================
    SELECT 
        COUNT(*) AS totalRegistros

    FROM tb_usuarios u

    INNER JOIN tb_estudiantes e 
        ON u.id = e.id

    WHERE 
        u.rol = 'Estudiante'

        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        AND (
            @CodigoEstudiante IS NULL
            OR e.codigoEstudiante LIKE '%' + @CodigoEstudiante + '%'
        )

        AND (
            @NombreCarrera IS NULL
            OR e.nombreCarrera LIKE '%' + @NombreCarrera + '%'
        )

        AND (
            @SemestreActual IS NULL
            OR e.semestreActual = @SemestreActual
        )

        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        );
END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EstudianteId')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateEstudiante')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteEstudiante')
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
/***************************************** USUARIOS **************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ResetContrasenaUsuario')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExisteEmailUsuario')
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
/***************************************** CRUD *************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Usuarios')
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
/*******************************************************************************************/
CREATE OR ALTER PROCEDURE usp_UsuariosPaginado
    @Pagina INT = 1,
    @TamanioPagina INT = 10,
    @Nombre NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Rol NVARCHAR(20) = NULL,
    @Activo BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- VALIDAR PAGINACIÓN
    -- ==========================================
    IF @Pagina < 1
        SET @Pagina = 1;

    IF @TamanioPagina < 1
        SET @TamanioPagina = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Pagina - 1) * @TamanioPagina;


    -- ==========================================
    -- LISTADO DE USUARIOS
    -- ==========================================
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

    LEFT JOIN tb_estudiantes e 
        ON u.id = e.id

    LEFT JOIN tb_docentes d 
        ON u.id = d.id

    WHERE 
        u.rol IN ('Director', 'Secretaria', 'Docente', 'Estudiante', 'Apoderado')

        -- Filtro por nombre
        AND (
            @Nombre IS NULL 
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        -- Filtro por email
        AND (
            @Email IS NULL 
            OR u.email LIKE '%' + @Email + '%'
        )

        -- Filtro por rol
        AND (
            @Rol IS NULL 
            OR u.rol = @Rol
        )

        -- Filtro por estado
        AND (
            @Activo IS NULL 
            OR u.activo = @Activo
        )

    ORDER BY 
        u.id,
        u.rol,
        u.nombreCompleto

    OFFSET @Offset ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;


    -- ==========================================
    -- TOTAL DE REGISTROS
    -- ==========================================
    SELECT 
        COUNT(*) AS totalRegistros

    FROM tb_usuarios u

    LEFT JOIN tb_estudiantes e 
        ON u.id = e.id

    LEFT JOIN tb_docentes d 
        ON u.id = d.id

    WHERE 
        u.rol IN ('Director', 'Secretaria', 'Docente', 'Estudiante', 'Apoderado')

        AND (
            @Nombre IS NULL 
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        AND (
            @Email IS NULL 
            OR u.email LIKE '%' + @Email + '%'
        )

        AND (
            @Rol IS NULL 
            OR u.rol = @Rol
        )

        AND (
            @Activo IS NULL 
            OR u.activo = @Activo
        );
END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UsuarioId')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateUsuario')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateUsuario')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteUsuario')
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
/****************************************** APODERADOS *************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ApoderadoDashboard')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ListHijos')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ListPeriodos')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ValidarEstudiante')
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
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LibretaNotas')
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
/****************************************** CRUD *************************************************/
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
/*******************************************************************************************/
CREATE OR ALTER PROCEDURE usp_ApoderadosPaginado
    @Pagina INT = 1,
    @TamanioPagina INT = 10,
    @Nombre NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Dni NVARCHAR(15) = NULL,
    @Telefono NVARCHAR(20) = NULL,
    @Direccion NVARCHAR(200) = NULL,
    @CantidadHijos INT = NULL,
    @Activo BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- VALIDAR PAGINACIÓN
    -- ==========================================
    IF @Pagina < 1
        SET @Pagina = 1;

    IF @TamanioPagina < 1
        SET @TamanioPagina = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Pagina - 1) * @TamanioPagina;


    -- ==========================================
    -- LISTADO PAGINADO
    -- ==========================================
    SELECT 
        u.id,
        u.nombreCompleto,
        u.email,
        u.activo,
        u.fechaRegistro,

        ISNULL(
            NULLIF(LTRIM(RTRIM(a.telefono)), ''),
            'Sin teléfono registrado'
        ) AS telefono,

        a.dni,

        ISNULL(
            NULLIF(LTRIM(RTRIM(a.direccion)), ''),
            'Sin dirección registrada'
        ) AS direccion,

        COUNT(ae.id) AS cantidadHijos

    FROM tb_usuarios u

    INNER JOIN tb_apoderados a 
        ON a.id = u.id

    LEFT JOIN tb_apoderadoEstudiante ae 
        ON ae.apoderadoId = u.id
        AND ae.activo = 1

    WHERE 
        u.rol = 'Apoderado'

        -- Filtro por nombre
        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        -- Filtro por email
        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        -- Filtro por DNI
        AND (
            @Dni IS NULL
            OR a.dni LIKE '%' + @Dni + '%'
        )

        -- Filtro por teléfono
        AND (
            @Telefono IS NULL
            OR a.telefono LIKE '%' + @Telefono + '%'
        )

        -- Filtro por dirección
        AND (
            @Direccion IS NULL
            OR a.direccion LIKE '%' + @Direccion + '%'
        )

        -- Filtro por estado
        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        )

    GROUP BY 
        u.id,
        u.nombreCompleto,
        u.email,
        u.activo,
        u.fechaRegistro,
        a.telefono,
        a.dni,
        a.direccion

    -- Filtro por cantidad de hijos
    HAVING (
        @CantidadHijos IS NULL
        OR COUNT(ae.id) = @CantidadHijos
    )

    ORDER BY 
        u.nombreCompleto

    OFFSET @Offset ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;


    -- ==========================================
    -- TOTAL DE REGISTROS
    -- ==========================================
    SELECT 
        COUNT(*) AS totalRegistros

    FROM (
        SELECT 
            u.id

        FROM tb_usuarios u

        INNER JOIN tb_apoderados a 
            ON a.id = u.id

        LEFT JOIN tb_apoderadoEstudiante ae 
            ON ae.apoderadoId = u.id
            AND ae.activo = 1

        WHERE 
            u.rol = 'Apoderado'

            AND (
                @Nombre IS NULL
                OR u.nombreCompleto LIKE '%' + @Nombre + '%'
            )

            AND (
                @Email IS NULL
                OR u.email LIKE '%' + @Email + '%'
            )

            AND (
                @Dni IS NULL
                OR a.dni LIKE '%' + @Dni + '%'
            )

            AND (
                @Telefono IS NULL
                OR a.telefono LIKE '%' + @Telefono + '%'
            )

            AND (
                @Direccion IS NULL
                OR a.direccion LIKE '%' + @Direccion + '%'
            )

            AND (
                @Activo IS NULL
                OR u.activo = @Activo
            )

        GROUP BY 
            u.id

        HAVING (
            @CantidadHijos IS NULL
            OR COUNT(ae.id) = @CantidadHijos
        )

    ) AS ApoderadosFiltrados;

END
GO
/*******************************************************************************************/
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
/*******************************************************************************************/
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
/*******************************************************************************************/
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
/*******************************************************************************************/
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
/*******************************************************************************************/
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
/*******************************************************************************************/
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
/*******************************************************************************************/
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
/****************************************** CURSOS *************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExisteCodigoCurso')
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
/******************************************* CRUD ************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Cursos')
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
/*******************************************************************************************/
CREATE OR ALTER PROCEDURE usp_CursosPaginado
    @Pagina INT = 1,
    @TamanioPagina INT = 10,
    @CodigoCurso NVARCHAR(20) = NULL,
    @NombreCurso NVARCHAR(100) = NULL,
    @Creditos TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- VALIDAR PAGINACIÓN
    -- ==========================================
    IF @Pagina < 1
        SET @Pagina = 1;

    IF @TamanioPagina < 1
        SET @TamanioPagina = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Pagina - 1) * @TamanioPagina;


    -- ==========================================
    -- LISTADO PAGINADO
    -- ==========================================
    SELECT 
        id,
        codigoCurso,
        nombreCurso,
        creditos,
        horasTeoricas,
        horasPracticas

    FROM tb_cursos

    WHERE
        -- Filtro por código
        (
            @CodigoCurso IS NULL
            OR codigoCurso LIKE '%' + @CodigoCurso + '%'
        )

        -- Filtro por nombre
        AND (
            @NombreCurso IS NULL
            OR nombreCurso LIKE '%' + @NombreCurso + '%'
        )

        -- Filtro por créditos
        AND (
            @Creditos IS NULL
            OR creditos = @Creditos
        )

    ORDER BY 
        codigoCurso

    OFFSET @Offset ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;


    -- ==========================================
    -- TOTAL DE REGISTROS
    -- ==========================================
    SELECT 
        COUNT(*) AS totalRegistros

    FROM tb_cursos

    WHERE
        (
            @CodigoCurso IS NULL
            OR codigoCurso LIKE '%' + @CodigoCurso + '%'
        )

        AND (
            @NombreCurso IS NULL
            OR nombreCurso LIKE '%' + @NombreCurso + '%'
        )

        AND (
            @Creditos IS NULL
            OR creditos = @Creditos
        );

END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CursoId')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateCurso')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateCurso')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteCurso')
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



/*******************************************************************************************/
/************************************** SECRETARIA *****************************************************/
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AsignarApoderadoEstudiante')
    DROP PROCEDURE usp_AsignarApoderadoEstudiante
GO

CREATE PROCEDURE usp_AsignarApoderadoEstudiante
    @apoderadoId        INT,
    @estudianteId       INT,
    @parentesco         NVARCHAR(50),
    @parentescoDetalle  NVARCHAR(100) = NULL
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ListApoderadosActivos')
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ListAsignacionApoderadoEstudianteVM')
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
/*******************************************************************************************/
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
/******************************************** CRUD ***********************************************/
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
/*******************************************************************************************/
CREATE OR ALTER PROCEDURE usp_SecretariasPaginado
    @Pagina INT = 1,
    @TamanioPagina INT = 10,
    @Nombre NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Cargo NVARCHAR(100) = NULL,
    @Telefono NVARCHAR(20) = NULL,
    @Activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- VALIDAR PAGINACIÓN
    -- ==========================================
    IF @Pagina < 1
        SET @Pagina = 1;

    IF @TamanioPagina < 1
        SET @TamanioPagina = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Pagina - 1) * @TamanioPagina;


    -- ==========================================
    -- LISTADO PAGINADO
    -- ==========================================
    SELECT 
        u.id,
        u.nombreCompleto,
        u.email,
        u.activo,
        u.fechaRegistro,
        s.cargo,
        s.telefono

    FROM tb_usuarios u

    INNER JOIN tb_secretarias s 
        ON u.id = s.id

    WHERE 
        u.rol = 'Secretaria'

        -- Filtro por nombre
        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        -- Filtro por email
        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        -- Filtro por cargo
        AND (
            @Cargo IS NULL
            OR s.cargo LIKE '%' + @Cargo + '%'
        )

        -- Filtro por teléfono
        AND (
            @Telefono IS NULL
            OR s.telefono LIKE '%' + @Telefono + '%'
        )

        -- Filtro por estado
        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        )

    ORDER BY 
        u.id,
        u.nombreCompleto

    OFFSET @Offset ROWS
    FETCH NEXT @TamanioPagina ROWS ONLY;


    -- ==========================================
    -- TOTAL DE REGISTROS
    -- ==========================================
    SELECT 
        COUNT(*) AS totalRegistros

    FROM tb_usuarios u

    INNER JOIN tb_secretarias s 
        ON u.id = s.id

    WHERE 
        u.rol = 'Secretaria'

        AND (
            @Nombre IS NULL
            OR u.nombreCompleto LIKE '%' + @Nombre + '%'
        )

        AND (
            @Email IS NULL
            OR u.email LIKE '%' + @Email + '%'
        )

        AND (
            @Cargo IS NULL
            OR s.cargo LIKE '%' + @Cargo + '%'
        )

        AND (
            @Telefono IS NULL
            OR s.telefono LIKE '%' + @Telefono + '%'
        )

        AND (
            @Activo IS NULL
            OR u.activo = @Activo
        );
END
GO
/*******************************************************************************************/
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_CreateSecretaria')
    DROP PROCEDURE usp_CreateSecretaria
GO

CREATE PROCEDURE usp_CreateSecretaria
    @id       INT,
    @cargo    NVARCHAR(100),
    @telefono NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tb_secretarias (id, cargo, telefono)
    VALUES (@id, @cargo, @telefono);

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_UpdateSecretaria')
    DROP PROCEDURE usp_UpdateSecretaria
GO

CREATE PROCEDURE usp_UpdateSecretaria
    @id             INT,
    @nombreCompleto NVARCHAR(100),
    @email          NVARCHAR(100),
    @activo         BIT,
    @cargo          NVARCHAR(100) = NULL,
    @telefono       NVARCHAR(20)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tb_usuarios
    SET nombreCompleto = @nombreCompleto,
        email          = @email,
        activo         = @activo
    WHERE id = @id AND rol = 'Secretaria';

    UPDATE tb_secretarias
    SET cargo    = @cargo,
        telefono = @telefono
    WHERE id = @id;

    SELECT @@ROWCOUNT AS FilasAfectadas;
END
GO
/*******************************************************************************************/
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
/*******************************************************************************************/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'p' AND name = 'usp_ExisteEmailSecretaria')
    DROP PROCEDURE usp_ExisteEmailSecretaria
GO

CREATE PROCEDURE usp_ExisteEmailSecretaria
    @email     NVARCHAR(100),
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