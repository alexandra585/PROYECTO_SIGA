
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class ApoderadoViewModel
    {
        public int id { get; set; }
        public string? nombreCompleto { get; set; }
        public string? email { get; set; }
        public bool activo { get; set; }
        public string? telefono { get; set; }
        public string? dni { get; set; }
        public string? direccion { get; set; }
        public int cantidadHijos { get; set; }
        public DateTime fechaRegistro { get; set; }
    }
}
