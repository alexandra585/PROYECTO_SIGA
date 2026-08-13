using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Docente")]
    public class DocenteController : Controller
    {
        private readonly IDocenteRepository _docenteRepository;

        public DocenteController(IDocenteRepository docenteRepository)
        {
            _docenteRepository = docenteRepository;
        }

        // =====================
        // DASHBOARD DEL DOCENTE
        // =====================
        [HttpGet]
        public async Task<IActionResult> Dashboard()
        {
            if (HttpContext.Session.GetString("Rol") != "Docente")
            {
                return RedirectToAction("IniciarSesion", "Auth");
            }

            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var model = await _docenteRepository.DocenteDashboard(usuarioId);

            return View(model);
        }

        // ================
        // CURSOS ASIGNADOS
        // ================
        [HttpGet]
        public async Task<IActionResult> CursosAsignados()
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var cursos = await _docenteRepository.CursosAsignadosDocente(usuarioId);
            return View(cursos);
        }

        // ==================
        // CURSOS ESTUDIANTES
        // ==================
        [HttpGet]
        public async Task<IActionResult> CursosEstudiantes(int cursoDocenteId = 0)
        {
            if (cursoDocenteId == 0)
            {
                return RedirectToAction("CursosAsignados");
            }

            int docenteId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var cursos = await _docenteRepository.CursosAsignadosDocente(docenteId);
            var curso = cursos.FirstOrDefault(c => c.CursoDocenteId == cursoDocenteId);
            ViewBag.NombreCurso = curso?.NombreCurso ?? "Curso";

            var estudiantes = await _docenteRepository.CursosEstudiantesDocente(cursoDocenteId);
            return View(estudiantes);
        }

        // ===============
        // REGISTRAR NOTAS
        // ===============
        [HttpGet]
        public async Task<IActionResult> RegistrarNotas(int? cursoDocenteId)
        {
            int docenteId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;

            if (!cursoDocenteId.HasValue)
            {
                var cursos = await _docenteRepository.CursosAsignadosDocente(docenteId);
                ViewBag.Cursos = new SelectList(cursos, "CursoDocenteId", "NombreCurso");
                return View();
            }

            var model = new RegistrarNotaViewModel
            {
                CursoDocenteId = cursoDocenteId.Value,
                NombreCurso = (await _docenteRepository.CursosAsignadosDocente(docenteId)).FirstOrDefault(c => c.CursoDocenteId == cursoDocenteId)?.NombreCurso ?? "",
                Estudiantes = await _docenteRepository.CursosEstudiantesDocente(cursoDocenteId.Value),
                Evaluaciones = await _docenteRepository.CursosEvaluacionesDocente(cursoDocenteId.Value)
            };

            var notasExistentes = await _docenteRepository.ObtenerNotasExistentes(cursoDocenteId.Value);
            ViewBag.NotasExistentes = notasExistentes;

            return View(model);
        }

        [HttpPost]
        public async Task<JsonResult> RegistrarNota(int matriculaId, int evaluacionId, decimal nota, string observacion)
        {
            int docenteId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            bool resultado = await _docenteRepository.RegistrarNotas(matriculaId, evaluacionId, nota, docenteId, observacion);
            return Json(new { success = resultado });
        }

        // ============================
        // OBTENER NOTAS POR ESTUDIANTE
        // ============================
        public async Task<JsonResult> ObtenerNotasEstudiante(int matriculaId)
        {
            var notas = await _docenteRepository.ObtenerNotasPorMatricula(matriculaId);
            return Json(notas);
        }
        
        // =====================
        // REGISTRAR ASISTENCIAS
        // =====================
        [HttpGet]
        public async Task<IActionResult> RegistrarAsistencias(int? cursoDocenteId, DateTime? fecha)
        {
            int docenteId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            DateTime fechaSeleccionada = fecha ?? DateTime.Today;

            if (!cursoDocenteId.HasValue)
            {
                var cursos = await _docenteRepository.CursosAsignadosDocente(docenteId);
                ViewBag.Cursos = new SelectList(cursos, "CursoDocenteId", "NombreCurso");
                ViewBag.FechaSeleccionada = fechaSeleccionada.ToString("yyyy-MM-dd");
                return View();
            }

            var model = new RegistrarAsistenciaViewModel
            {
                CursoDocenteId = cursoDocenteId.Value,
                NombreCurso = (await _docenteRepository.CursosAsignadosDocente(docenteId))
                    .FirstOrDefault(c => c.CursoDocenteId == cursoDocenteId)?.NombreCurso ?? "",
                FechaSeleccionada = fechaSeleccionada,
                Asistencias = await _docenteRepository.ObtenerAsistenciasPorCurso(cursoDocenteId.Value, fechaSeleccionada)
            };

            return View(model);
        }

        [HttpPost]
        public async Task<JsonResult> RegistrarAsistencias(int matriculaId, string estado, string observacion)
        {
            int docenteId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            bool resultado = await _docenteRepository.RegistrarAsistencias(matriculaId, estado, docenteId, observacion);
            return Json(new { success = resultado });
        }

        // ================================
        // OBTENER HISTORIAL DE ASISTENCIAS
        // ================================
        public async Task<JsonResult> ObtenerHistorialAsistencias(int cursoDocenteId, DateTime fecha)
        {
            var asistencias = await _docenteRepository.ObtenerAsistenciasPorCurso(cursoDocenteId, fecha);
            return Json(asistencias);
        }

        // ================
        // REPORTE DE CURSO
        // =================
        [HttpGet]
        public async Task<IActionResult> ReporteCurso(int? cursoDocenteId)
        {
            int docenteId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;

            if (!cursoDocenteId.HasValue)
            {
                var cursos = await _docenteRepository.CursosAsignadosDocente(docenteId);
                ViewBag.Cursos = new SelectList(cursos, "CursoDocenteId", "NombreCurso");
                return View();
            }

            var reporte = await _docenteRepository.ObtenerReporteCurso(cursoDocenteId.Value);
            return View(reporte);
        }
    }
}
