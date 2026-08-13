using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Apoderado")]
    public class ApoderadoController : Controller
    {
        private readonly IApoderadoRepository _apoderadoRepository;

        public ApoderadoController(IApoderadoRepository apoderadoRepository)
        {
            _apoderadoRepository = apoderadoRepository;
        }

        // =======================
        // DASHBOARD DEL APODERADO
        // =======================
        [HttpGet]
        public async Task<IActionResult> Dashboard()
        {
            int? apoderadoId = HttpContext.Session.GetInt32("UsuarioId");
            if (apoderadoId == null)
            {
                return RedirectToAction("IniciarSesion", "Auth");
            }

            var model = await _apoderadoRepository.ApoderadoDashboard(apoderadoId.Value);
            return View(model);
        }

        // =================
        // FILTRO DE LIBRETA
        // =================
        [HttpGet]
        public async Task<IActionResult> FilterLibreta()
        {
            int? apoderadoId = HttpContext.Session.GetInt32("UsuarioId");

            if (apoderadoId == null)
                return RedirectToAction("IniciarSesion", "Auth");

            var model = new ApoderadoLibretaFiltroViewModel
            {
                Hijos = await _apoderadoRepository.ListHijos(apoderadoId.Value),
                Periodos = await _apoderadoRepository.ListPeriodos()
            };

            if (model.Hijos.Count == 1)
                model.EstudianteId = model.Hijos[0].EstudianteId;

            return View(model);
        }

        // ==============================
        // RESULTADO DE FILTRO DE LIBRETA
        // ==============================
        [HttpGet]
        public async Task<IActionResult> ResultFilterLibreta(int estudianteId, int? periodoId)
        {
            int? apoderadoId = HttpContext.Session.GetInt32("UsuarioId");

            if (apoderadoId == null)
                return RedirectToAction("IniciarSesion", "Auth");

            if (estudianteId <= 0)
            {
                TempData["Error"] = "Selecciona un estudiante válido.";
                return RedirectToAction("FilterLibreta");
            }

            var libreta = await _apoderadoRepository.LibretaNotas(apoderadoId.Value, estudianteId, periodoId);

            if (libreta == null)
            {
                TempData["Error"] = "No tiene permiso para ver este estudiante o no existe el vínculo.";
                return RedirectToAction("FilterLibreta");
            }

            return View(libreta);
        }
    }
}
