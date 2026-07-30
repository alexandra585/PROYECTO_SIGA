using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    public class AuthController : Controller
    {
        private readonly ILoginRepository _loginRepository;

        public AuthController(ILoginRepository loginRepository)
        {
            _loginRepository = loginRepository;
        }

        // ================
        // INICIO DE SESIÓN
        // ================
        [HttpGet]
        public IActionResult IniciarSesion()
        {
            if (HttpContext.Session.GetInt32("UsuarioId").HasValue)
            {
                return RedirectToAction("Dashboard", GetDashboardController());
            }

            return View(new LoginViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> IniciarSesion(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Error = "Complete todos los campos correctamente";
                return View(model);
            }

            try
            {
                var usuario = await _loginRepository.ValidarUsuario(model.email, model.contrasenia);

                if (usuario == null)
                {
                    ViewBag.Error = "Inicio de sesión no válido. Verifique sus credenciales.";
                    return View(model);
                }

                HttpContext.Session.SetInt32("UsuarioId", usuario.id);
                HttpContext.Session.SetString("NombreUsuario", usuario.nombreCompleto);
                HttpContext.Session.SetString("Rol", usuario.rol);
                HttpContext.Session.SetString("Email", usuario.email);

                return RedirectToAction("Dashboard", GetDashboardController());
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Ocurrió un error al iniciar sesión. Intente nuevamente.";
                return View(model);
            }
        }

        // ==========================
        // RECUPERACIÓN DE CONTRASEÑA
        // ==========================
        [HttpGet]
        public IActionResult RecuperarContrasenia()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> RecuperarContrasenia(string email)
        {
            ViewBag.Mensaje = "Se ha enviado un enlace de recuperación a su correo. Revise su bandeja de entrada/spam.";
            return View();
        }

        // =============
        // CERRAR SESIÓN
        // =============
        [HttpGet]
        public IActionResult CerrarSesion()
        {
            HttpContext.Session.Clear();
            HttpContext.Session.Remove("UsuarioId");
            HttpContext.Session.Remove("NombreUsuario");
            HttpContext.Session.Remove("Rol");
            HttpContext.Session.Remove("Email");

            HttpContext.Session.Remove("SessionId");

            TempData["Mensaje"] = "Sesión cerrada correctamente.";
            TempData["TipoMensaje"] = "success";

            return RedirectToAction("IniciarSesion");
        }

        private string GetDashboardController()
        {
            var rol = HttpContext.Session.GetString("Rol");

            return rol switch
            {
                "Director" => "Director",
                "Secretaria" => "Secretaria",
                "Docente" => "Docente",
                "Estudiante" => "Estudiante",
                "Apoderado" => "Apoderado",
                _ => "Home"
            };
        }

        private bool IsAuthenticated()
        {
            return HttpContext.Session.GetInt32("UsuarioId").HasValue;
        }
    }
}