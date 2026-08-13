using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Director")]
    public class CRUDDocenteController : Controller
    {
        private readonly ICRUDDocenteRepository _crudDocenteRepository;

        public CRUDDocenteController(ICRUDDocenteRepository crudDocenteRepository)
        {
            _crudDocenteRepository = crudDocenteRepository;
        }

        // ===============
        // LISTAR DOCENTES
        // ===============
        [HttpGet]
        public async Task<IActionResult> ListDocente(
            int pagina = 1,
            int tamanioPagina = 1, // 10
            string? nombre = null,
            string? email = null,
            string? especialidad = null,
            string? gradoAcademico = null,
            bool? activo = true)
        {
            var resultado = await _crudDocenteRepository.ListDocente(
                pagina,
                tamanioPagina,
                nombre,
                email,
                especialidad,
                gradoAcademico,
                activo
            );

            return View(resultado);
        }

        // =============
        // CREAR DOCENTE
        // =============
        [HttpGet]
        public IActionResult CreateDocente()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateDocente(DocenteViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudDocenteRepository.ExisteEmailDocente(model.email))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    int nuevoId = await _crudDocenteRepository.CreateUsuarioDocente(model);

                    if (nuevoId > 0)
                    {
                        bool resultado = await _crudDocenteRepository.CreateDocente(nuevoId, model);

                        if (resultado)
                        {
                            TempData["Success"] = "Docente creado exitosamente";
                            TempData["TipoMensaje"] = "success";
                            return RedirectToAction("ListDocente");
                        }
                    }

                    TempData["Error"] = "Error al crear el docente";
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
        // EDITAR DOCENTE
        // ==============
        [HttpGet]
        public async Task<IActionResult> EditDocente(int id)
        {
            var docente = await _crudDocenteRepository.DocenteId(id);

            if (docente == null)
            {
                TempData["Error"] = "Docente no encontrado";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListDocente");
            }

            return View(docente);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditDocente(DocenteViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudDocenteRepository.ExisteEmailDocente(model.email, model.id))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    bool resultado = await _crudDocenteRepository.UpdateDocente(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Docente actualizado exitosamente";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListDocente");
                    }

                    TempData["Error"] = "Error al actualizar el docente";
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

        // ================
        // ELIMINAR DOCENTE
        // ================
        [HttpGet]
        public async Task<IActionResult> DeleteDocente(int id)
        {
            var docente = await _crudDocenteRepository.DocenteId(id);

            if (docente == null)
            {
                TempData["Error"] = "Docente no encontrado";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListDocente");
            }

            return View(docente);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                bool resultado = await _crudDocenteRepository.DeleteDocente(id);

                if (resultado)
                {
                    TempData["Success"] = "Docente eliminado exitosamente";
                    TempData["TipoMensaje"] = "success";
                }
                else
                {
                    TempData["Error"] = "Error al eliminar el docente. Puede que tenga asignaciones activas.";
                    TempData["TipoMensaje"] = "error";
                }
            }
            catch (Microsoft.Data.SqlClient.SqlException)
            {
                TempData["Error"] = "No se puede eliminar el docente porque tiene asignaciones asociadas";
                TempData["TipoMensaje"] = "error";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListDocente");
        }
    }
}
