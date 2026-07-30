using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class EstudianteDashboardViewModel
    {
        public string nombreCompleto { get; set; }
        public string codigoEstudiante { get; set; }
        public string nombreCarrera { get; set; }
        public int semestreActual { get; set; }
        public double promedioGeneral { get; set; }
        public List<CursoMatriculado> CursosMatriculados { get; set; }
    }
}