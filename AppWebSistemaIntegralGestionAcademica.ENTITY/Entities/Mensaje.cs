
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class Mensaje
    {
        public long id { get; set; }
        public int conversacionId { get; set; }
        public int remitenteId { get; set; }
        public string contenido { get; set; } = string.Empty;
        public DateTime fechaEnvio { get; set; }
        public bool leido { get; set; }
    }
}
