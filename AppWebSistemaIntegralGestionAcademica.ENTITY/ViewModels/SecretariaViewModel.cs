
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class SecretariaViewModel
    {
        public int id { get; set; }
        public string? nombreCompleto { get; set; }
        public string? email { get; set; }
        public string? cargo { get; set; }
        public string? telefono { get; set; }
        public bool activo { get; set; }
        public DateTime fechaRegistro { get; set; }
    }
}
