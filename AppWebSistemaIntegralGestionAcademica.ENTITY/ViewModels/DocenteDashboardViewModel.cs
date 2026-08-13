using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class DocenteDashboardViewModel
    {
        public string nombreCompleto { get; set; }
        public string especialidad { get; set; }
        public string gradoAcademico { get; set; }
        public int totalCursosAsignados { get; set; }
        public List<CursoDocente> CursosAsignados { get; set; }
    }
}