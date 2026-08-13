
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class DirectorDashboardViewModel
    {
        public int TotalEstudiantes { get; set; }
        public int TotalDocentes { get; set; }
        public int TotalCursos { get; set; }
        public int TotalSecretarias { get; set; }
        public int TotalApoderados { get; set; }
        public int TotalMatriculasActivas { get; set; }
        public string? PeriodoActivo { get; set; }
    }
}