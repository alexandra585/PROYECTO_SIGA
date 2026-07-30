using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Director")]
    public class CRUDSecretariaController : Controller
    {
        private readonly ICRUDSecretariaRepository _crudSecretariaRepository;

        public CRUDSecretariaController(ICRUDSecretariaRepository crudSecretariaRepository)
        {
            _crudSecretariaRepository = crudSecretariaRepository;
        }

        // ==================
        // LISTAR SECRETARIAS
        // ==================
        [HttpGet]
        public async Task<IActionResult> ListSecretaria()
        {
            var secretarias = await _crudSecretariaRepository.ListSecretaria();
            return View(secretarias);
        }

        // ================
        // CREAR SECRETARIA
        // ================
        [HttpGet]
        public IActionResult CreateSecretaria()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateSecretaria(SecretariaViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudSecretariaRepository.ExisteEmailSecretaria(model.email))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    int nuevoId = await _crudSecretariaRepository.CreateUsuarioSecretaria(model);

                    if (nuevoId > 0)
                    {
                        bool resultado = await _crudSecretariaRepository.CreateSecretaria(nuevoId, model);

                        if (resultado)
                        {
                            TempData["Success"] = "Secretaria creada exitosamente. Contraseña inicial: 123456";
                            TempData["TipoMensaje"] = "success";
                            return RedirectToAction("ListSecretaria");
                        }
                    }

                    TempData["Error"] = "Error al crear la secretaria";
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

        // =================
        // EDITAR SECRETARIA
        // =================
        [HttpGet]
        public async Task<IActionResult> EditSecretaria(int id)
        {
            var secretaria = await _crudSecretariaRepository.SecretariaId(id);

            if (secretaria == null)
            {
                TempData["Error"] = "Secretaria no encontrada";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListSecretaria");
            }

            return View(secretaria);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditSecretaria(SecretariaViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudSecretariaRepository.ExisteEmailSecretaria(model.email, model.id))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    bool resultado = await _crudSecretariaRepository.UpdateSecretaria(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Secretaria actualizada exitosamente";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListSecretaria");
                    }

                    TempData["Error"] = "Error al actualizar la secretaria";
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

        // ===================
        // ELIMINAR SECRETARIA
        // ===================
        [HttpGet]
        public async Task<IActionResult> DeleteSecretaria(int id)
        {
            var secretaria = await _crudSecretariaRepository.SecretariaId(id);

            if (secretaria == null)
            {
                TempData["Error"] = "Secretaria no encontrada";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListSecretaria");
            }

            return View(secretaria);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                bool resultado = await _crudSecretariaRepository.DeleteSecretaria(id);

                if (resultado)
                {
                    TempData["Success"] = "Secretaria eliminada exitosamente";
                    TempData["TipoMensaje"] = "success";
                }
                else
                {
                    TempData["Error"] = "Error al eliminar la secretaria";
                    TempData["TipoMensaje"] = "error";
                }
            }
            catch (Microsoft.Data.SqlClient.SqlException)
            {
                TempData["Error"] = "No se puede eliminar la secretaria porque tiene registros asociados";
                TempData["TipoMensaje"] = "error";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListSecretaria");
        }
    }
}
