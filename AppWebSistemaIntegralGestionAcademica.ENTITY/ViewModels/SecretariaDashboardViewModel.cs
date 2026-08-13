
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class SecretariaDashboardViewModel
    {
        public int TotalAsignacionesCursoDocente { get; set; }
        public int TotalMatriculas { get; set; }
        public int TotalAsignacionesApoderadoEstudiante { get; set; }
        public string? PeriodoActivo { get; set; }
    }
}
