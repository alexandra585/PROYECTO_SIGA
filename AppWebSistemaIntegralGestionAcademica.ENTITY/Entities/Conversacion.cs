
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class Conversacion
    {
        public int id { get; set; }
        public int apoderadoId { get; set; }
        public int docenteId { get; set; }
        public int? cursoId { get; set; }
        public DateTime fechaCreacion { get; set; }
        public string? ultimoMensaje { get; set; }
        public DateTime? ultimoMensajeFecha { get; set; }
    }
}
