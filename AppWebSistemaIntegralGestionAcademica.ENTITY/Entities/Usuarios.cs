
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class Usuarios
    {
        public int id { get; set; }
        public string? nombreCompleto { get; set; }
        public string? email { get; set; }
        public string? contrasenia { get; set; }
        public string? rol { get; set; }
        public DateTime fechaRegistro { get; set; }
        public bool activo { get; set; }
        public int numeroIntentos { get; set; }
    }
}