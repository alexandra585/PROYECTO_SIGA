													/* INICIO DEL SCRIPT */
-- USO DE LA BASE DE DATOS
USE DBSIGA
GO

-- INSERCCIÓN DE DATOS
-- ===================
-- 1. Tabla: Usuarios (CONTRASEÑA: 123456)
-- ===================
-- DIRECTOR (ID 1)
INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
VALUES
('Carlos Ramírez Morales', 'director@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Director', 1);
--- SECRETARIA (ID 2)
INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
VALUES
('Camila Cruz Janto', 'secretaria@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Secretaria', 1);

-- DOCENTES (ID 3 - ID 7)
INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
VALUES 
('María López Cruz', 'docente@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Docente', 1),
('Juan Martínez Pérez', 'juan@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Docente', 1),
('Ana González Rodríguez', 'ana@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Docente', 1),
('Pedro Sánchez García', 'pedro@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Docente', 1),
('Laura Fernández Torres', 'laura@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Docente', 1);
-- ESTUDIANTES (ID 8 - ID 22)
INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
VALUES 
('Marco Pérez Arbeloa', 'estudiante@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Monica Gutiérrez Díaz', 'monica@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('José Andrés Mendoza López', 'jose@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Susan Lucía Castro Paredes', 'susan@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Javier Eduardo Rojas Silva', 'javier@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Kevin Morales Ríos', 'kevin@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Andrea Paredes León', 'andrea@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Luis Alberto Ramos', 'luisr@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Fernanda Castillo Vega', 'fernanda@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Diego Herrera Flores', 'diego@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Valeria Navarro Ruiz', 'valeria@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Cristian Mendoza Soto', 'cristian@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Paola Benites Díaz', 'paola@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Renzo Vargas Peña', 'renzo@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1),
('Camila Rojas Silva', 'camilars@gmail.com', '8d969eef6ecad3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Estudiante', 1);
-- APODERADO (ID 23 - ID 32)
INSERT INTO tb_usuarios (nombreCompleto, email, contrasenia, rol, activo)
VALUES 
('Roberto Pérez Mendoza', 'apoderado@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Carmen Díaz Sánchez', 'carmen@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Luis Torres Ramírez', 'luis@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Patricia Gómez Flores', 'patricia@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Miguel Ángel Castro', 'miguel@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Ana María Ruiz Vargas', 'anamaria@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('José Luis Fernández', 'joseluis@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('María Elena Soto', 'mariaelena@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Ricardo Salazar Ortiz', 'ricardo@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1),
('Verónica Navarro Peña', 'veronica@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Apoderado', 1);


-- ===================
-- 2. Tabla: Docentes
-- ===================
INSERT INTO tb_docentes (id, especialidad, gradoAcademico)
VALUES
(3, 'Ingeniería de Sistemas', 'Magíster'),
(4, 'Ingeniería de Software', 'Doctor'),
(5, 'Bases de Datos', 'Magíster'),
(6, 'Programación Web', 'Magíster'),
(7, 'Seguridad Informática', 'Doctor');

-- ======================
-- 3. Tabla: Estudiantes
-- ======================
INSERT INTO tb_estudiantes (id, codigoEstudiante, nombreCarrera, semestreActual)
VALUES 
(8,  'I20250001', 'Computación e Informática', 2),
(9,  'I20250002', 'Computación e Informática', 1),
(10, 'I20250003', 'Computación e Informática', 2),
(11, 'I20250004', 'Computación e Informática', 1),
(12, 'I20250005', 'Computación e Informática', 2),
(13, 'I20250006', 'Computación e Informática', 1),
(14, 'I20250007', 'Computación e Informática', 2),
(15, 'I20250008', 'Computación e Informática', 1),
(16, 'I20250009', 'Computación e Informática', 2),
(17, 'I20250010', 'Computación e Informática', 1),
(18, 'I20250011', 'Computación e Informática', 2),
(19, 'I20250012', 'Computación e Informática', 1),
(20, 'I20250013', 'Computación e Informática', 2),
(21, 'I20250014', 'Computación e Informática', 1),
(22, 'I20250015', 'Computación e Informática', 2);

-- ============================
-- 4. Tabla: Periodo Académico
-- ============================
INSERT INTO tb_periodoAcademico (nombrePeriodo, fechaInicio, fechaFin, esActivo)
VALUES
('2026-I', '2026-03-01', '2026-07-30', 0),
('2026-II', '2026-08-01', '2026-12-30', 1);

-- ================
-- 5. Tabla: Curso
-- ================
INSERT INTO tb_cursos (codigoCurso, nombreCurso, creditos, horasTeoricas, horasPracticas)
VALUES 
('POOI-A01', 'Programación Orientada a Objetos I', 4, 3, 2),
('POOI-A02', 'Programación Orientada a Objetos II', 4, 3, 2),
('BDAV-A01', 'Base de Datos Avanzado I', 3, 2, 2),
('BDAV-A02', 'Base de Datos Avanzado II', 3, 2, 2),
('LPRO-A01', 'Lenguaje de Programación I', 4, 3, 2),
('LPRO-A02', 'Lenguaje de Programación II', 4, 3, 2),
('ARWE-A01', 'Arquitectura de Entornos Web', 3, 2, 2),
('DEWE-A01', 'Desarrollo de Entornos Web', 4, 2, 3),
('SEAP-A01', 'Seguridad de Aplicaciones', 3, 2, 2),
('DAMO-A01', 'Desarrollo de Aplicaciones Móviles I', 4, 2, 3);

-- =======================
-- 6. Tabla: CursoDocente
-- =======================
INSERT INTO tb_cursoDocente (cursoId, docenteId, periodoAcademicoId)
VALUES
(1, 3, 2),
(2, 4, 2),
(3, 5, 2),
(4, 6, 2),
(5, 7, 2);

-- =====================
-- 7. Tabla: Matriculas
-- =====================
INSERT INTO tb_matriculas (estudianteId, cursoDocenteId, estado)
VALUES
(8, 1, 'Activo'),
(8, 2, 'Activo'),
(8, 3, 'Activo'),
(9, 1, 'Activo'),
(9, 2, 'Activo'),
(9, 4, 'Activo'),
(10, 1, 'Activo'),
(10, 3, 'Activo'),
(10, 5, 'Activo'),
(11, 2, 'Activo'),
(11, 4, 'Activo'),
(11, 5, 'Activo'),
(12, 3, 'Activo'),
(12, 4, 'Activo'),
(12, 5, 'Activo');

-- ==========================
-- 8. Tabla: TiposEvaluacion
-- ==========================
INSERT INTO tb_tipoEvaluacion (nombre, notaEvaluacion)
VALUES 
('Parcial I', 30.00),
('Parcial II', 30.00),
('Examen Final', 40.00);

-- =======================
-- 9. Tabla: Evaluaciones
-- =======================
INSERT INTO tb_evaluaciones (cursoDocenteId, tipoEvaluacionId, fechaEvaluacion, notaPorcentual)
VALUES 
(1, 1, '2026-09-15', 30.00),
(1, 2, '2026-11-15', 30.00),
(1, 3, '2026-12-15', 40.00),
(2, 1, '2026-09-20', 30.00),
(2, 2, '2026-11-20', 30.00),
(2, 3, '2026-12-20', 40.00),
(3, 1, '2026-09-25', 30.00),
(3, 2, '2026-11-25', 30.00),
(3, 3, '2026-12-25', 40.00),
(4, 1, '2026-10-01', 30.00),
(4, 2, '2026-11-01', 30.00),
(4, 3, '2026-12-01', 40.00),
(5, 1, '2026-10-05', 30.00),
(5, 2, '2026-11-05', 30.00),
(5, 3, '2026-12-05', 40.00);

-- =================
-- 10. Tabla: Notas
-- =================
INSERT INTO tb_notas (matriculaId, evaluacionId, nota, docenteRegistroId, observacion)
VALUES 
(1, 1, 15.50, 3, 'Buen desempeño en el primer parcial'),
(1, 2, 14.00, 3, 'Debe reforzar conceptos'),
(1, 3, 16.00, 3, 'Examen final aprobado'),
(2, 4, 17.00, 5, 'Excelente en SQL'),
(2, 5, 18.00, 5, 'Muy bien en procedimientos'),
(2, 6, 19.00, 5, 'Dominio de BD'),
(3, 7, 14.50, 6, 'Buen inicio en HTML/CSS'),
(3, 8, 15.00, 6, 'Mejorando en JS'),
(3, 9, 16.00, 6, 'Aprobó el curso'),
(4, 1, 18.00, 3, 'Excelente en POO'),
(4, 2, 17.50, 3, 'Muy buen desempeño'),
(4, 3, 19.00, 3, 'Sobresaliente'),
(5, 4, 16.00, 5, 'Buen manejo de consultas'),
(5, 5, 15.50, 5, 'Requiere más práctica'),
(5, 6, 17.00, 5, 'Mejoró notablemente'),
(6, 10, 17.00, 7, 'Excelente en seguridad'),
(6, 11, 18.00, 7, 'Buen manejo de cifrado'),
(6, 12, 19.00, 7, 'Proyecto destacado'),
(7, 1, 13.00, 3, 'Necesita mejorar fundamentos'),
(7, 2, 12.50, 3, 'Debe practicar más'),
(7, 3, 14.00, 3, 'Aprobó el curso'),
(8, 7, 15.00, 6, 'Buen manejo de CSS'),
(8, 8, 14.00, 6, 'Requiere más JS'),
(8, 9, 15.50, 6, 'Aprobó con proyecto funcional'),
(9, 13, 14.00, 4, 'Buen inicio en móviles'),
(9, 14, 15.00, 4, 'Mejorando interfaces'),
(9, 15, 16.00, 4, 'Aprobó el curso'),
(10, 4, 18.50, 5, 'Excelente en BD Avanzada'),
(10, 5, 19.00, 5, 'Dominio de procedimientos'),
(10, 6, 20.00, 5, 'Perfecto en el final'),
(11, 10, 16.50, 7, 'Buen manejo de seguridad'),
(11, 11, 17.00, 7, 'Excelente en criptografía'),
(11, 12, 18.00, 7, 'Proyecto sobresaliente'),
(12, 13, 15.00, 4, 'Buen inicio'),
(12, 14, 16.00, 4, 'Mejorando'),
(12, 15, 17.00, 4, 'Aprobó con éxito'),
(13, 7, 12.00, 6, 'Requiere más práctica'),
(13, 8, 11.50, 6, 'Dificultades con JS'),
(13, 9, 13.00, 6, 'Aprobó mínimamente'),
(14, 10, 14.00, 7, 'Conceptos básicos claros'),
(14, 11, 15.00, 7, 'Mejoró en seguridad'),
(14, 12, 16.00, 7, 'Aprobó el curso'),
(15, 13, 13.50, 4, 'Dificultades iniciales'),
(15, 14, 14.00, 4, 'Mejorando progresivamente'),
(15, 15, 15.00, 4, 'Logró aprobar');

-- ==============================
-- 11. Tabla: ApoderadoEstudiante
-- ==============================
INSERT INTO tb_apoderadoEstudiante
(apoderadoId, estudianteId, parentesco, activo)
VALUES
(23, 8, 'Padre', 1),
(23, 9, 'Padre', 1),
(23, 13, 'Padre', 1),
(24, 10, 'Madre', 1),
(24, 14, 'Madre', 1),
(25, 11, 'Padre', 1),
(25, 15, 'Padre', 1),
(26, 12, 'Madre', 1),
(26, 16, 'Madre', 1),
(27, 17, 'Tutor', 1),
(27, 18, 'Tutor', 1),
(27, 19, 'Tutor', 1),
(28, 20, 'Tutor', 1),
(28, 21, 'Tutor', 1),
(29, 22, 'Padre', 1);

-- ======================
-- 12. Tabla: Secretarias
-- ======================
INSERT INTO tb_secretarias (id, cargo, telefono)
VALUES
(2, 'Secretaria Académica', '987654321');

-- =====================
-- 13. TABLA: Apoderados
-- =====================
INSERT INTO tb_apoderados (id, telefono, dni, direccion)
VALUES
(23, '999111001', '70123456', NULL),
(24, '999111002', '70123457', NULL),
(25, '999111003', '70123458', NULL),
(26, '999111004', '70123459', NULL),
(27, '999111005', '70123460', NULL),
(28, '999111006', '70123461', NULL),
(29, '999111007', '70123462', NULL),
(30, '999111008', '70123463', NULL),
(31, '999111009', '70123464', NULL),
(32, '999111010', '70123465', NULL);
GO
													/* FIN DEL SCRIPT */