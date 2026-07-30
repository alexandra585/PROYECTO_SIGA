using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class AsignacionCursoDocenteViewModel
    {
        public List<DocenteViewModel> Docentes { get; set; }
        public List<CursoViewModel> Cursos { get; set; }
        public List<PeriodoAcademico> Periodos { get; set; }
    }

    public class AsignacionCursoDocenteVM
    {
        public int Id { get; set; }
        public string CodigoCurso { get; set; }
        public string NombreCurso { get; set; }
        public string NombreDocente { get; set; }
        public string NombrePeriodo { get; set; }
        public int CantidadMatriculados { get; set; }
    }

    public class AsignacionCursoEstudianteViewModel
    {
        public List<EstudianteViewModel> Estudiantes { get; set; }
        public List<CursoDocenteEstudiante> CursoDocente { get; set; }
    }

    public class AsignacionCursoEstudianteVM
    {
        public int Id { get; set; }
        public string CodigoEstudiante { get; set; }
        public string NombreEstudiante { get; set; }
        public string CodigoCurso { get; set; }
        public string NombreCurso { get; set; }
        public string NombreDocente { get; set; }
        public string NombrePeriodo { get; set; }
        public string Estado { get; set; }
        public DateTime FechaMatricula { get; set; }
        public int CantidadNotas { get; set; }
        public int CantidadAsistencias { get; set; }
        public bool TieneRegistros => CantidadNotas > 0 || CantidadAsistencias > 0;
    }
    public class AsignacionApoderadoEstudianteViewModel
    {
        public List<UsuarioSimpleVM> Apoderados { get; set; } = new();
        public List<EstudianteSimpleVM> Estudiantes { get; set; } = new();
    }

    public class UsuarioSimpleVM
    {
        public int Id { get; set; }
        public string NombreCompleto { get; set; } = "";
        public string Email { get; set; } = "";
    }

    public class EstudianteSimpleVM
    {
        public int Id { get; set; }
        public string NombreCompleto { get; set; } = "";
        public string CodigoEstudiante { get; set; } = "";
        public string NombreCarrera { get; set; } = "";
        public int SemestreActual { get; set; }
    }

    public class ApoderadoEstudianteDetalleVM
    {
        public int Id { get; set; }
        public int EstudianteId { get; set; }
        public string NombreEstudiante { get; set; } = "";
        public string CodigoEstudiante { get; set; } = "";
        public string Parentesco { get; set; } = "";
        public string? ParentescoDetalle { get; set; }
        public DateTime FechaRegistro { get; set; }
    }

    public class ApoderadoAsignacionGrupoVM
    {
        public int ApoderadoId { get; set; }
        public string NombreApoderado { get; set; } = "";
        public string EmailApoderado { get; set; } = "";
        public int CantidadHijos { get; set; }
        public List<ApoderadoEstudianteDetalleVM> Hijos { get; set; } = new();
    }
}