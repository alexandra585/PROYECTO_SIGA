using System.ComponentModel.DataAnnotations;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "El email es obligatorio")]
        [EmailAddress(ErrorMessage = "Formato de email no válido")]
        [Display(Name = "Correo Electrónico")]
        public string? email { get; set; }

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [DataType(DataType.Password)]
        [Display(Name = "Contraseña")]
        public string? contrasenia { get; set; }

        [Display(Name = "Recordarme")]
        public bool Recordarme { get; set; }
    }

    public class RecuperarContraseniaViewModel
    {
        [Required(ErrorMessage = "El correo electrónico es obligatorio")]
        [EmailAddress(ErrorMessage = "Formato de email no válido")]
        [Display(Name = "Correo Electrónico")]
        public string? Email { get; set; }
    }
}