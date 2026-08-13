
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class Curso
    {
        public int id { get; set; }
        public string codigoCurso { get; set; }
        public string nombreCurso { get; set; }
        public int creditos { get; set; }
        public int? horasTeoricas { get; set; }
        public int? horasPracticas { get; set; }
    }
}