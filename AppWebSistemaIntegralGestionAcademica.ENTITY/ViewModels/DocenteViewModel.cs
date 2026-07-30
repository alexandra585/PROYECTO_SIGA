
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class DocenteViewModel
    {
        public int id { get; set; }
        public string? nombreCompleto { get; set; }
        public string? email { get; set; }
        public string? especialidad { get; set; }
        public string? gradoAcademico { get; set; }
        public bool activo { get; set; }
    }
}