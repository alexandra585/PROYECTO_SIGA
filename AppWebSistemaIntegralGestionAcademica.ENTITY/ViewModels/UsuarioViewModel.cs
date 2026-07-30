using System.ComponentModel.DataAnnotations;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class UsuarioViewModel
    {
        public int id { get; set; }

        [Required(ErrorMessage = "El nombre completo es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede exceder los 100 caracteres")]
        public string? nombreCompleto { get; set; }

        [Required(ErrorMessage = "El email es obligatorio")]
        [EmailAddress(ErrorMessage = "Formato de email no válido")]
        public string? email { get; set; }

        public string? rol { get; set; }

        public bool activo { get; set; } = true;

        public DateTime fechaRegistro { get; set; }

        public int numeroIntentos { get; set; }

        public string? codigoEstudiante { get; set; }

        public string? especialidad { get; set; }
    }
}