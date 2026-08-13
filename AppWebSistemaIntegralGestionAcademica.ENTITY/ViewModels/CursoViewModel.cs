using System.ComponentModel.DataAnnotations;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class CursoViewModel
    {
        public int id { get; set; }

        [Required(ErrorMessage = "El código del curso es obligatorio")]
        [StringLength(20, MinimumLength = 3, ErrorMessage = "El código debe tener entre 3 y 20 caracteres")]
        public string? codigoCurso { get; set; }

        [Required(ErrorMessage = "El nombre del curso es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede exceder los 100 caracteres")]
        public string? nombreCurso { get; set; }

        [Required(ErrorMessage = "Los créditos son obligatorios")]
        [Range(0, 7, ErrorMessage = "Los créditos deben estar entre 0 y 7")]
        public int creditos { get; set; }

        [Range(0, 10, ErrorMessage = "Las horas teóricas deben estar entre 0 y 10")]
        public int horasTeoricas { get; set; }

        [Range(0, 10, ErrorMessage = "Las horas prácticas deben estar entre 0 y 10")]
        public int horasPracticas { get; set; }
    }
}