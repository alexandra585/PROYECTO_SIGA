
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class CursoEstudianteNotaViewModel
    {
        public int MatriculaId { get; set; }
        public int CursoId { get; set; }
        public string CodigoCurso { get; set; }
        public string NombreCurso { get; set; }
        public int Creditos { get; set; }
        public int CursoDocenteId { get; set; }
        public string NombreDocente { get; set; }
        public string EstadoMatricula { get; set; }
        public double PromedioActual { get; set; }
    }

    public class NotaDetalleViewModel
    {
        public int EvaluacionId { get; set; }
        public string TipoEvaluacion { get; set; }
        public DateTime FechaEvaluacion { get; set; }
        public decimal PesoPorcentual { get; set; }
        public decimal NotaObtenida { get; set; }
        public string Observacion { get; set; }
        public DateTime? FechaRegistro { get; set; }
    }

    public class ResumenNotaViewModel
    {
        public int CursoId { get; set; }
        public string CodigoCurso { get; set; }
        public string NombreCurso { get; set; }
        public int Creditos { get; set; }
        public double PromedioFinal { get; set; }
        public string Estado { get; set; }
    }

    public class AsistenciaEstudianteViewModel
    {
        public string NombreCurso { get; set; }
        public string CodigoCurso { get; set; }
        public DateTime Fecha { get; set; }
        public string Estado { get; set; }
        public string Observacion { get; set; }
        public TimeSpan? HoraRegistro { get; set; }
    }

    public class ReporteAcademicoViewModel
    {
        public string NombreCompleto { get; set; }
        public string Email { get; set; }
        public string CodigoEstudiante { get; set; }
        public string Carrera { get; set; }
        public int SemestreActual { get; set; }
        public double PromedioGeneral { get; set; }
        public int TotalCreditosAprobados { get; set; }
        public List<ResumenNotaViewModel> Cursos { get; set; }
    }
}