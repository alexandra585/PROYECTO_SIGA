using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Secretaria")]
    public class SecretariaController : Controller
    {
        private readonly ISecretariaRepository _secretariaRepository;

        public SecretariaController(ISecretariaRepository secretariaRepository)
        {
            _secretariaRepository = secretariaRepository;
        }

        // ==========================
        // DASHBOARD DE LA SECRETARIA
        // ==========================
        [HttpGet]
        public async Task<IActionResult> Dashboard()
        {
            if (HttpContext.Session.GetString("Rol") != "Secretaria")
            {
                return RedirectToAction("IniciarSesion", "Auth");
            }

            var model = await _secretariaRepository.SecretariaDashboard();
            return View(model);
        }

        // =======================
        // ASIGNAR CURSO A DOCENTE
        // =======================
        [HttpGet]
        public async Task<IActionResult> AsignarCursoDocente()
        {
            var model = await _secretariaRepository.AsignacionCursoDocenteViewModel();
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AsignarCursoDocente(int docenteId, int cursoId, int periodoId)
        {
            if (docenteId <= 0 || cursoId <= 0 || periodoId <= 0)
            {
                TempData["Error"] = "Seleccione todos los campos correctamente";
                return RedirectToAction("AsignarCursoDocente");
            }

            var resultado = await _secretariaRepository.AsignarCursoDocente(docenteId, cursoId, periodoId);

            if (resultado)
            {
                TempData["Success"] = "Docente asignado correctamente al curso";
                TempData["TipoMensaje"] = "success";
            }
            else
            {
                TempData["Error"] = "Error al asignar el docente. Verifique que la asignación no exista";
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("AsignarCursoDocente");
        }

        // ==========================
        // ASIGNAR CURSO A ESTUDIANTE
        // ==========================
        [HttpGet]
        public async Task<IActionResult> AsignarCursoEstudiante()
        {
            var model = await _secretariaRepository.AsignacionCursoEstudianteViewModel();
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AsignarCursoEstudiante(int alumnoId, int cursoDocenteId)
        {
            if (alumnoId <= 0 || cursoDocenteId <= 0)
            {
                TempData["Error"] = "Seleccione todos los campos correctamente";
                return RedirectToAction("AsignarCursoEstudiante");
            }

            var resultado = await _secretariaRepository.AsignarCursoEstudiante(alumnoId, cursoDocenteId);

            if (resultado)
            {
                TempData["Success"] = "Estudiante matriculado correctamente";
                TempData["TipoMensaje"] = "success";
            }
            else
            {
                TempData["Error"] = "Error al matricular el estudiante. Verifique que la matrícula no exista";
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("AsignarCursoEstudiante");
        }

        // ====================
        // LISTADO ASIGNACIONES
        // ====================
        [HttpGet]
        public async Task<IActionResult> ListAsignarCursoDocente()
        {
            var asignaciones = await _secretariaRepository.ListAsignacionCursoDocenteViewModel();
            return View(asignaciones);
        }

        // ==========================
        // DESASIGNAR CURSO - DOCENTE
        // ==========================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DesasignarCursoDocenteViewModel(int id)
        {
            if (id <= 0)
            {
                TempData["Error"] = "Asignación no válida";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListAsignarCursoDocente");
            }

            int resultado = await _secretariaRepository.DesasignarCursoDocenteViewModel(id);

            if (resultado > 0)
            {
                TempData["Success"] = "Asignación eliminada correctamente";
                TempData["TipoMensaje"] = "success";
            }
            else if (resultado == -1)
            {
                TempData["Error"] = "No se puede desasignar: ya hay estudiantes matriculados";
                TempData["TipoMensaje"] = "error";
            }
            else if (resultado == -2)
            {
                TempData["Error"] = "No se puede desasignar: existen evaluaciones registradas";
                TempData["TipoMensaje"] = "error";
            }
            else
            {
                TempData["Error"] = "No se pudo desasignar la asignación";
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("AsignarCursoDocente");
        }

        // ==================
        // LISTADO MATRÍCULAS
        // ==================
        [HttpGet]
        public async Task<IActionResult> ListAsignarCursoEstudiante()
        {
            var matriculas = await _secretariaRepository.ListAsignacionCursoEstudianteViewModel();
            return View(matriculas);
        }

        // =============================
        // DESASIGNAR CURSO - ESTUDIANTE
        // =============================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DesasignarCursoEstudianteViewModel(int id)
        {
            if (id <= 0)
            {
                TempData["Error"] = "Matrícula no válida";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListAsignarCursoEstudiante");
            }

            int resultado = await _secretariaRepository.DesasignarCursoEstudianteViewModel(id);

            if (resultado > 0)
            {
                TempData["Success"] = "Matrícula eliminada correctamente";
                TempData["TipoMensaje"] = "success";
            }
            else if (resultado == -1)
            {
                TempData["Error"] = "No se puede desasignar: el estudiante ya tiene notas registradas";
                TempData["TipoMensaje"] = "error";
            }
            else if (resultado == -2)
            {
                TempData["Error"] = "No se puede desasignar: el estudiante ya tiene asistencias registradas";
                TempData["TipoMensaje"] = "error";
            }
            else
            {
                TempData["Error"] = "No se pudo desasignar la matrícula";
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("AsignarCursoEstudiante");
        }

        // ==============================
        // ASIGNAR APODERADO – ESTUDIANTE
        // ==============================
        [HttpGet]
        public async Task<IActionResult> AsignarApoderadoEstudiante()
        {
            var model = await _secretariaRepository.AsignacionApoderadoEstudianteViewModel();
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AsignarApoderadoEstudiante(int apoderadoId, int estudianteId, string parentesco, string? parentescoDetalle)
        {
            if (apoderadoId <= 0 || estudianteId <= 0 || string.IsNullOrWhiteSpace(parentesco))
            {
                TempData["Error"] = "Seleccione apoderado, estudiante y parentesco correctamente.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("AsignarApoderadoEstudiante");
            }

            if (parentesco == "Otro" && string.IsNullOrWhiteSpace(parentescoDetalle))
            {
                TempData["Error"] = "Cuando el parentesco es 'Otro', debe indicar el detalle.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("AsignarApoderadoEstudiante");
            }

            var resultado = await _secretariaRepository.AsignarApoderadoEstudiante(apoderadoId, estudianteId, parentesco, parentescoDetalle);

            switch (resultado)
            {
                case > 0:
                    TempData["Success"] = "Apoderado asignado correctamente al estudiante.";
                    TempData["TipoMensaje"] = "success";
                    break;
                case -1:
                    TempData["Error"] = "El apoderado seleccionado no es válido o está inactivo.";
                    TempData["TipoMensaje"] = "error";
                    break;
                case -2:
                    TempData["Error"] = "El estudiante seleccionado no es válido o está inactivo.";
                    TempData["TipoMensaje"] = "error";
                    break;
                case -3:
                    TempData["Error"] = "Esta asignación ya existe.";
                    TempData["TipoMensaje"] = "error";
                    break;
                default:
                    TempData["Error"] = "No se pudo realizar la asignación.";
                    TempData["TipoMensaje"] = "error";
                    break;
            }

            return RedirectToAction("AsignarApoderadoEstudiante");
        }

        // ====================
        // LISTADO ASIGNACIONES
        // ====================
        [HttpGet]
        public async Task<IActionResult> ListAsignarApoderadoEstudiante()
        {
            var model = await _secretariaRepository.ListAsignacionApoderadoEstudianteViewModel();
            return View(model);
        }

        // =================================
        // DESASIGNAR APODERADO - ESTUDIANTE
        // =================================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DesasignarApoderadoEstudianteViewModel(int id)
        {
            if (id <= 0)
            {
                TempData["Error"] = "Asignación no válida.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListAsignarApoderadoEstudiante");
            }

            var resultado = await _secretariaRepository.DesasignarApoderadoEstudianteViewModel(id);

            if (resultado > 0)
            {
                TempData["Success"] = "Asignación eliminada correctamente.";
                TempData["TipoMensaje"] = "success";
            }
            else
            {
                TempData["Error"] = "No se pudo desasignar.";
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("AsignarApoderadoEstudiante");
        }
    }
}
