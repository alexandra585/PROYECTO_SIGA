
													/* INICIO DEL SCRIPT */
-- CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE DBSIGA
GO

-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- CREACIÓN DE TABLAS
-- ===========================================================
-- 1. Tabla: Usuarios (0 = INACTIVO, FALSE, 1 = ACTIVO, TRUE)
-- ===========================================================
CREATE TABLE tb_usuarios (
    id				INT PRIMARY KEY IDENTITY(1,1),
    nombreCompleto	NVARCHAR(100) NOT NULL,
    email			NVARCHAR(100) UNIQUE NOT NULL,
    contrasenia		NVARCHAR(255) NOT NULL,
    rol				NVARCHAR(20) NOT NULL CHECK (Rol IN ('Director', 'Secretaria', 'Docente', 'Estudiante', 'Apoderado')),
    fechaRegistro	DATETIME DEFAULT GETDATE(),
    activo			BIT DEFAULT 1,
    numeroIntentos	INT DEFAULT 0,
);

-- =====================================================================
-- 2. Tabla: PeriodosAcademicos (0 = INACTIVO, FALSE, 1 = ACTIVO, TRUE)
-- =====================================================================
CREATE TABLE tb_periodoAcademico (
    id				INT PRIMARY KEY IDENTITY(1,1),
    nombrePeriodo	NVARCHAR(50) NOT NULL,                              -- "2026-I, 2026-II, etc."
    fechaInicio		DATE NOT NULL,
    fechaFin		DATE NOT NULL,
    esActivo		BIT DEFAULT 0
);

-- ================
-- 3. Tabla: Cursos
-- ================
CREATE TABLE tb_cursos (
    id				INT PRIMARY KEY IDENTITY(1,1),
    codigoCurso		NVARCHAR(20) UNIQUE NOT NULL,						-- "POOI-A01"
    nombreCurso		NVARCHAR(100) NOT NULL,								-- "Programación Orientada a Objetos I"
    creditos		TINYINT NOT NULL CHECK (creditos BETWEEN 1 AND 6),
    horasTeoricas	TINYINT,
    horasPracticas	TINYINT
);

-- =====================
-- 4. Tabla: Estudiantes
-- =====================
CREATE TABLE tb_estudiantes (
    id					INT PRIMARY KEY,
    codigoEstudiante	NVARCHAR(20) UNIQUE NOT NULL,													-- "I20250000, etc."
    nombreCarrera		NVARCHAR(100) NOT NULL,
    semestreActual		TINYINT CHECK (semestreActual BETWEEN 1 AND 2),
	CONSTRAINT FK_Estudiante_Usuario FOREIGN KEY (id) REFERENCES tb_usuarios(id) ON DELETE CASCADE
);

-- ==================
-- 5. Tabla: Docentes
-- ==================
CREATE TABLE tb_docentes (
    id					INT PRIMARY KEY,
    especialidad		NVARCHAR(100),
    gradoAcademico		NVARCHAR(50),																	-- "Magíster, Doctor, etc."
	CONSTRAINT FK_Docente_Usuario FOREIGN KEY (id) REFERENCES tb_usuarios(id) ON DELETE CASCADE
);

-- ======================
-- 6. Tabla: CursoDocente
-- ======================
CREATE TABLE tb_cursoDocente (
    id					INT PRIMARY KEY IDENTITY(1,1),
    cursoId				INT NOT NULL,
    docenteId			INT NOT NULL,
    periodoAcademicoId	INT NOT NULL,
	CONSTRAINT FK_CursoDocente_Curso FOREIGN KEY (cursoId) REFERENCES tb_cursos(id),
    CONSTRAINT FK_CursoDocente_Docente FOREIGN KEY (docenteId) REFERENCES tb_docentes(id),
    CONSTRAINT FK_CursoDocente_Periodo FOREIGN KEY (periodoAcademicoId) REFERENCES tb_periodoAcademico(id)
);

-- ====================
-- 7. Tabla: Matriculas
-- ====================
CREATE TABLE tb_matriculas (
    id					INT PRIMARY KEY IDENTITY(1,1),
    estudianteId		INT NOT NULL,
    cursoDocenteId		INT NOT NULL,
    fechaMatricula		DATETIME DEFAULT GETDATE(),
    estado				NVARCHAR(20) DEFAULT 'Activo' CHECK (estado IN ('Activo', 'Retirado', 'Aprobado', 'Desaprobado')),
	CONSTRAINT FK_Matricula_Estudiante FOREIGN KEY (estudianteId) REFERENCES tb_estudiantes(id),
    CONSTRAINT FK_Matricula_CursoDocente FOREIGN KEY (cursoDocenteId) REFERENCES tb_cursoDocente(id)
);

-- =========================
-- 8. Tabla: TiposEvaluacion
-- =========================
CREATE TABLE tb_tipoEvaluacion (
    id				INT PRIMARY KEY IDENTITY(1,1),
    nombre			NVARCHAR(100) NOT NULL,									-- "Parcial-I, Pacial II, Final, etc."
    notaEvaluacion	DECIMAL(4,2) CHECK (notaEvaluacion BETWEEN 0 AND 100)
);

-- ======================
-- 9. Tabla: Evaluaciones
-- ======================
CREATE TABLE tb_evaluaciones (
    id					INT PRIMARY KEY IDENTITY(1,1),
    cursoDocenteId		INT NOT NULL,
    tipoEvaluacionId	INT NOT NULL,
    fechaEvaluacion		DATE NOT NULL,
    notaPorcentual		DECIMAL(4,2) NOT NULL CHECK (notaPorcentual BETWEEN 0 AND 100),
	CONSTRAINT FK_Evaluacion_CursoDocente FOREIGN KEY (cursoDocenteId) REFERENCES tb_cursoDocente(id),
    CONSTRAINT FK_Evaluacion_TipoEvaluacion FOREIGN KEY (tipoEvaluacionId) REFERENCES tb_tipoEvaluacion(id)
);

-- ================
-- 10. Tabla: Notas
-- ================
CREATE TABLE tb_notas (
    id					INT PRIMARY KEY IDENTITY(1,1),
    matriculaId			INT NOT NULL,
    evaluacionId		INT NOT NULL,
    nota				DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 20),
    fechaRegistro		DATETIME DEFAULT GETDATE(),
    docenteRegistroId	INT NOT NULL,
    observacion			NVARCHAR(255) NULL,
	CONSTRAINT FK_Nota_Matricula FOREIGN KEY (matriculaId) REFERENCES tb_matriculas(id),
    CONSTRAINT FK_Nota_Evaluacion FOREIGN KEY (evaluacionId) REFERENCES tb_evaluaciones(id),
    CONSTRAINT FK_Nota_Docente FOREIGN KEY (docenteRegistroId) REFERENCES tb_docentes(id)
);

-- ======================
-- 11. TABLA: Asistencias
-- ======================
CREATE TABLE tb_asistencias (
    id					INT PRIMARY KEY IDENTITY(1,1),
    matriculaId			INT NOT NULL,
    fecha				DATE NOT NULL,
    estado				NVARCHAR(20) NOT NULL CHECK (estado IN ('Presente', 'Ausente', 'Justificado', 'Tardanza')),
    horaRegistro		TIME DEFAULT GETDATE(),
    docenteRegistroId	INT NOT NULL,
    observacion			NVARCHAR(255) NULL,
    fechaRegistro		DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Asistencia_Matricula FOREIGN KEY (matriculaId) REFERENCES tb_matriculas(id),
    CONSTRAINT FK_Asistencia_Docente FOREIGN KEY (docenteRegistroId) REFERENCES tb_docentes(id),
    CONSTRAINT UQ_Asistencia_Unica UNIQUE (matriculaId, fecha)
);

-- ==============================
-- 12. TABLA: ApoderadoEstudiante
-- ==============================
CREATE TABLE tb_apoderadoEstudiante (
    id              INT PRIMARY KEY IDENTITY(1,1),
    apoderadoId     INT NOT NULL,
    estudianteId    INT NOT NULL,
    parentesco      NVARCHAR(50) NOT NULL CHECK (parentesco IN ('Padre', 'Madre', 'Tutor', 'Otro')),
    activo          BIT DEFAULT 1,
    fechaRegistro   DATETIME DEFAULT GETDATE(),
	parentescoDetalle NVARCHAR(50) NULL
    CONSTRAINT FK_ApoderadoEstudiante_Apoderado FOREIGN KEY (apoderadoId) REFERENCES tb_usuarios(id),
    CONSTRAINT FK_ApoderadoEstudiante_Estudiante FOREIGN KEY (estudianteId) REFERENCES tb_estudiantes(id),
    CONSTRAINT UQ_Apoderado_Estudiante UNIQUE (apoderadoId, estudianteId)
);
GO

-- ======================
-- 13. TABLA: Secretarias
-- ======================
CREATE TABLE tb_secretarias (
    id          INT PRIMARY KEY,
    cargo       NVARCHAR(100) NULL,          -- "Secretaria Académica, Asistente de mesa, etc."
    telefono    NVARCHAR(20)  NULL,
    CONSTRAINT FK_Secretaria_Usuario FOREIGN KEY (id) REFERENCES tb_usuarios(id) ON DELETE CASCADE
);

-- =====================
-- 14. TABLA: Apoderados
-- =====================
CREATE TABLE tb_apoderados (
    id          INT PRIMARY KEY,
    telefono    NVARCHAR(20)  NULL,
    dni         NVARCHAR(15)  UNIQUE NOT NULL,
    direccion   NVARCHAR(200) NULL,
    CONSTRAINT FK_Apoderado_Usuario FOREIGN KEY (id) REFERENCES tb_usuarios(id) ON DELETE CASCADE
);
													/* FIN DEL SCRIPT */