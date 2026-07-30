
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class CursoDocente
    {
        public int id { get; set; }
        public int cursoId { get; set; }
        public int docenteId { get; set; }
        public int periodoAcademicoId { get; set; }
        public string nombreCurso { get; set; }
        public string codigoCurso { get; set; }
        public string nombrePeriodo { get; set; }
    }
}