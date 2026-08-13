
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class ConversacionUsuario
    {
        public int conversacionId { get; set; }
        public int usuarioId { get; set; }
        public bool eliminado { get; set; }
        public DateTime? fechaEliminacion { get; set; }
        public DateTime? limpiadoHasta { get; set; }
    }
}
