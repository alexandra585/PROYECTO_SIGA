
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class Nota
    {
        public int id { get; set; }
        public int matriculaId { get; set; }
        public int evaluacionId { get; set; }
        public decimal nota { get; set; }
        public DateTime fechaRegistro { get; set; }
        public string observacion { get; set; }
        public string nombreEvaluacion { get; set; }
        public decimal porcentaje { get; set; }
    }
}