using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Director")]
    public class CRUDCursoController : Controller
    {
        private readonly ICRUDCursoRepository _crudCursoRepository;

        public CRUDCursoController(ICRUDCursoRepository crudCursoRepository)
        {
            _crudCursoRepository = crudCursoRepository;
        }

        // =============
        // LISTAR CURSOS
        // =============
        [HttpGet]
        public async Task<IActionResult> ListCurso()
        {
            var cursos = await _crudCursoRepository.ListCurso();
            return View(cursos);
        }

        // ===========
        // CREAR CURSO
        // ===========
        [HttpGet]
        public IActionResult CreateCurso()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateCurso(CursoViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudCursoRepository.ExisteCodigoCurso(model.codigoCurso))
                    {
                        ModelState.AddModelError("codigoCurso", "El código del curso ya existe");
                        return View(model);
                    }

                    bool resultado = await _crudCursoRepository.CreateCurso(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Curso creado exitosamente";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListCurso");
                    }

                    TempData["Error"] = "Error al crear el curso";
                    TempData["TipoMensaje"] = "error";
                }
                catch (Exception ex)
                {
                    TempData["Error"] = "Error: " + ex.Message;
                    TempData["TipoMensaje"] = "error";
                }
            }
            return View(model);
        }

        // ============
        // EDITAR CURSO
        // ============
        [HttpGet]
        public async Task<IActionResult> EditCurso(int id)
        {
            var curso = await _crudCursoRepository.CursoId(id);

            if (curso == null)
            {
                TempData["Error"] = "Curso no encontrado";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListCurso");
            }

            return View(curso);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditCurso(CursoViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudCursoRepository.ExisteCodigoCurso(model.codigoCurso, model.id))
                    {
                        ModelState.AddModelError("codigoCurso", "El código del curso ya existe");
                        return View(model);
                    }

                    bool resultado = await _crudCursoRepository.UpdateCurso(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Curso actualizado exitosamente";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListCurso");
                    }

                    TempData["Error"] = "Error al actualizar el curso";
                    TempData["TipoMensaje"] = "error";
                }
                catch (Exception ex)
                {
                    TempData["Error"] = "Error: " + ex.Message;
                    TempData["TipoMensaje"] = "error";
                }
            }
            return View(model);
        }

        // ==============
        // ELIMINAR CURSO
        // ==============
        [HttpGet]
        public async Task<IActionResult> DeleteCurso(int id)
        {
            var curso = await _crudCursoRepository.CursoId(id);

            if (curso == null)
            {
                TempData["Error"] = "Curso no encontrado";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListCurso");
            }

            return View(curso);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                bool resultado = await _crudCursoRepository.DeleteCurso(id);

                if (resultado)
                {
                    TempData["Success"] = "Curso eliminado exitosamente";
                    TempData["TipoMensaje"] = "success";
                }
                else
                {
                    TempData["Error"] = "Error al eliminar el curso. Puede que tenga asignaciones activas.";
                    TempData["TipoMensaje"] = "error";
                }
            }
            catch (Microsoft.Data.SqlClient.SqlException)
            {
                TempData["Error"] = "No se puede eliminar el curso porque tiene asignaciones (docentes, matrículas)";
                TempData["TipoMensaje"] = "error";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListCurso");
        }
    }
}
