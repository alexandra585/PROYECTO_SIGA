													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS - DIRECTORES
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
/*-------------------------------------------------------------------------------------------------*/
