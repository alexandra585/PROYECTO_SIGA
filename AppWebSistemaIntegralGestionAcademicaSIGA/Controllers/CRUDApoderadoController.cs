using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Director")]
    public class CRUDApoderadoController : Controller
    {
        private readonly ICRUDApoderadoRepository _crudApoderadoRepository;

        public CRUDApoderadoController(ICRUDApoderadoRepository crudApoderadoRepository)
        {
            _crudApoderadoRepository = crudApoderadoRepository;
        }

        // =================
        // LISTAR APODERADOS
        // =================
        [HttpGet]
        public async Task<IActionResult> ListApoderado()
        {
            var apoderados = await _crudApoderadoRepository.ListApoderado();
            return View(apoderados);
        }

        // ===============
        // CREAR APODERADO
        // ===============
        [HttpGet]
        public IActionResult CreateApoderado()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateApoderado(ApoderadoViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudApoderadoRepository.ExisteEmailApoderado(model.email))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    if (await _crudApoderadoRepository.ExisteDniApoderado(model.dni))
                    {
                        ModelState.AddModelError("dni", "El DNI ya está registrado");
                        return View(model);
                    }

                    int nuevoId = await _crudApoderadoRepository.CreateUsuarioApoderado(model);

                    if (nuevoId > 0)
                    {
                        bool resultado = await _crudApoderadoRepository.CreateApoderado(nuevoId, model);

                        if (resultado)
                        {
                            TempData["Success"] = "Apoderado creado exitosamente. Contraseña inicial: 123456";
                            TempData["TipoMensaje"] = "success";
                            return RedirectToAction("ListApoderado");
                        }
                    }

                    TempData["Error"] = "Error al crear el apoderado";
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

        // ===============
        // EDIAR APODERADO
        // ===============
        [HttpGet]
        public async Task<IActionResult> EditApoderado(int id)
        {
            var apoderado = await _crudApoderadoRepository.ApoderadoId(id);

            if (apoderado == null)
            {
                TempData["Error"] = "Apoderado no encontrado";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListApoderado");
            }

            return View(apoderado);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditApoderado(ApoderadoViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudApoderadoRepository.ExisteEmailApoderado(model.email, model.id))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    if (await _crudApoderadoRepository.ExisteDniApoderado(model.dni, model.id))
                    {
                        ModelState.AddModelError("dni", "El DNI ya está registrado");
                        return View(model);
                    }

                    bool resultado = await _crudApoderadoRepository.UpdateApoderado(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Apoderado actualizado exitosamente";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListApoderado");
                    }

                    TempData["Error"] = "Error al actualizar el apoderado";
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

        // ==================
        // ELIMINAR APODERADO
        // ==================
        [HttpGet]
        public async Task<IActionResult> DeleteApoderado(int id)
        {
            var apoderado = await _crudApoderadoRepository.ApoderadoId(id);

            if (apoderado == null)
            {
                TempData["Error"] = "Apoderado no encontrado";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListApoderado");
            }

            return View(apoderado);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                bool resultado = await _crudApoderadoRepository.DeleteApoderado(id);

                if (resultado)
                {
                    TempData["Success"] = "Apoderado eliminado exitosamente";
                    TempData["TipoMensaje"] = "success";
                }
                else
                {
                    TempData["Error"] = "Error al eliminar el apoderado. Puede que tenga registros asociados.";
                    TempData["TipoMensaje"] = "error";
                }
            }
            catch (Microsoft.Data.SqlClient.SqlException)
            {
                TempData["Error"] = "No se puede eliminar el apoderado porque tiene registros asociados";
                TempData["TipoMensaje"] = "error";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListApoderado");
        }
    }
}
