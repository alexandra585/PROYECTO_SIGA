using System.ComponentModel.DataAnnotations;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class EstudianteViewModel
    {
        public int id { get; set; }

        [Required(ErrorMessage = "El nombre completo es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede exceder los 100 caracteres")]
        public string? nombreCompleto { get; set; }

        [Required(ErrorMessage = "El email es obligatorio")]
        [EmailAddress(ErrorMessage = "Formato de email no válido")]
        public string? email { get; set; }

        [Required(ErrorMessage = "El código de estudiante es obligatorio")]
        [StringLength(20, MinimumLength = 8, ErrorMessage = "El código debe tener entre 8 y 20 caracteres")]
        public string? codigoEstudiante { get; set; }

        [Required(ErrorMessage = "El nombre de la carrera es obligatoria")]
        [StringLength(100, ErrorMessage = "La carrera no puede exceder los 100 caracteres")]
        public string? nombreCarrera { get; set; }

        [Required(ErrorMessage = "El semestre es obligatorio")]
        [Range(0, 3, ErrorMessage = "El semestre debe estar entre 0 y 3")]
        public int semestreActual { get; set; }

        public bool activo { get; set; }

        public DateTime fechaRegistro { get; set; }
    }
}