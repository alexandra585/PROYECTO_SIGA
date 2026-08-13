using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class ApoderadoHijoViewModel
    {
        public int EstudianteId { get; set; }
        public string NombreCompleto { get; set; }
        public string CodigoEstudiante { get; set; }
        public string Parentesco { get; set; }
    }

    public class ApoderadoLibretaFiltroViewModel
    {
        public int? EstudianteId { get; set; }
        public int? PeriodoId { get; set; }
        public List<ApoderadoHijoViewModel> Hijos { get; set; } = new();
        public List<PeriodoAcademico> Periodos { get; set; } = new();
        public ApoderadoLibretaViewModel Libreta { get; set; }
    }

    public class ApoderadoLibretaViewModel
    {
        public int EstudianteId { get; set; }
        public string NombreEstudiante { get; set; }
        public string CodigoEstudiante { get; set; }
        public string Parentesco { get; set; }
        public List<ApoderadoPeriodoNotasViewModel> Periodos { get; set; } = new();
    }

    public class ApoderadoPeriodoNotasViewModel
    {
        public int PeriodoId { get; set; }
        public string NombrePeriodo { get; set; }
        public bool EsActivo { get; set; }
        public List<ApoderadoCursoNotasViewModel> Cursos { get; set; } = new();
    }

    public class ApoderadoCursoNotasViewModel
    {
        public string CodigoCurso { get; set; }
        public string NombreCurso { get; set; }
        public string NombreDocente { get; set; }
        public decimal? Promedio { get; set; }
        public List<ApoderadoNotaDetalleViewModel> Notas { get; set; } = new();
    }

    public class ApoderadoNotaDetalleViewModel
    {
        public string TipoEvaluacion { get; set; }
        public decimal? Nota { get; set; }
        public decimal? Peso { get; set; }
        public DateTime? FechaEvaluacion { get; set; }
    }
}
