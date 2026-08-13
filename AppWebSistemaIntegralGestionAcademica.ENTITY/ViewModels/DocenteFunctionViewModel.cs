
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class CursoDocenteViewModel
    {
        public int CursoDocenteId { get; set; }
        public int CursoId { get; set; }
        public string CodigoCurso { get; set; }
        public string NombreCurso { get; set; }
        public int Creditos { get; set; }
        public string NombrePeriodo { get; set; }
        public int PeriodoId { get; set; }
    }

    public class CursoEstudianteViewModel
    {
        public int MatriculaId { get; set; }
        public int EstudianteId { get; set; }
        public string NombreCompleto { get; set; }
        public string CodigoEstudiante { get; set; }
        public string NombreCarrera { get; set; }
        public int SemestreActual { get; set; }
        public string EstadoMatricula { get; set; }
        public double PromedioActual { get; set; }
    }

    public class EvaluacionNotaViewModel
    {
        public int EvaluacionId { get; set; }
        public string Nombre { get; set; }
        public string TipoEvaluacion { get; set; }
        public DateTime FechaEvaluacion { get; set; }
        public decimal NotaPorcentual { get; set; }
    }

    public class NotaViewModel
    {
        public int NotaId { get; set; }
        public int EvaluacionId { get; set; }
        public string? NombreEvaluacion { get; set; }
        public decimal Nota { get; set; }
        public string? Observacion { get; set; }
        public DateTime? FechaRegistro { get; set; }
    }

    public class AsistenciaViewModel
    {
        public int MatriculaId { get; set; }
        public int EstudianteId { get; set; }
        public string? NombreCompleto { get; set; }
        public string? CodigoEstudiante { get; set; }
        public string? EstadoAsistencia { get; set; }
        public string? Observacion { get; set; }
        public TimeSpan? HoraRegistro { get; set; }
    }

    public class ReporteCursoViewModel
    {
        public string NombreCurso { get; set; }
        public string CodigoCurso { get; set; }
        public int Creditos { get; set; }
        public string NombreDocente { get; set; }
        public string NombrePeriodo { get; set; }
        public int TotalEstudiantes { get; set; }
        public int TotalAprobados { get; set; }
        public int TotalDesaprobados { get; set; }
        public int TotalSinNotas { get; set; }
        public double PromedioGeneralCurso { get; set; }
        public List<CursoEstudianteViewModel> Estudiantes { get; set; }
    }

    public class RegistrarNotaViewModel
    {
        public int CursoDocenteId { get; set; }
        public string NombreCurso { get; set; }
        public List<CursoEstudianteViewModel> Estudiantes { get; set; }
        public List<EvaluacionNotaViewModel> Evaluaciones { get; set; }
    }

    public class RegistrarAsistenciaViewModel
    {
        public int CursoDocenteId { get; set; }
        public string NombreCurso { get; set; }
        public DateTime FechaSeleccionada { get; set; }
        public List<AsistenciaViewModel> Asistencias { get; set; }
    }
}