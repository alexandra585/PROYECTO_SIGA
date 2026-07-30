
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class Matricula
    {
        public int id { get; set; }
        public int estudianteId { get; set; }
        public int cursoDocenteId { get; set; }
        public DateTime fechaMatricula { get; set; }
        public string estado { get; set; }
        public string nombreCurso { get; set; }
        public string nombreDocente { get; set; }
        public double promedio { get; set; }
    }
}