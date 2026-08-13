
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities
{
    public class CursoMatriculado
    {
        public int matriculaId { get; set; }
        public int cursoDocenteId { get; set; }
        public string nombreCurso { get; set; }
        public string codigoCurso { get; set; }
        public string estado { get; set; }
        public double notaFinal { get; set; }
        public string estadoNota { get; set; }
    }
}