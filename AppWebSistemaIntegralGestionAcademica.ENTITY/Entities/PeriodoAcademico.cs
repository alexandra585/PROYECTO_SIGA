
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class PeriodoAcademico
    {
        public int id { get; set; }
        public string? nombrePeriodo { get; set; }
        public DateTime fechaInicio { get; set; }
        public DateTime fechaFin { get; set; }
        public bool esActivo { get; set; }
    }
}