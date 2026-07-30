using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    public class InicioController : Controller
    {
        public IActionResult Inicio()
        {
            return View();
        }
    }
}
