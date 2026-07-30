
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class ApoderadoDashboardViewModel
    {
        public string NombreApoderado { get; set; }
        public int TotalHijos { get; set; }
        public string PeriodoActivo { get; set; }
        public List<ApoderadoHijoViewModel> Hijos { get; set; } = new();
    }
}
