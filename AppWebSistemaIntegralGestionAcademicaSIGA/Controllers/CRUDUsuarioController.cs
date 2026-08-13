using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Director")]
    public class CRUDUsuarioController : Controller
    {
        private readonly ICRUDUsuarioRepository _crudUsuarioRepository;

        public CRUDUsuarioController(ICRUDUsuarioRepository crudUsuarioRepository)
        {
            _crudUsuarioRepository = crudUsuarioRepository;
        }

        // ===============
        // LISTAR USUARIOS
        // ===============
        [HttpGet]
        public async Task<IActionResult> ListUsuario()
        {
            var usuarios = await _crudUsuarioRepository.ListUsuario();
            return View(usuarios);
        }

        // =============
        // CREAR USUARIO
        // =============
        [HttpGet]
        public IActionResult CreateUsuario()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateUsuario(UsuarioViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudUsuarioRepository.ExisteEmailUsuario(model.email))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    int nuevoId = await _crudUsuarioRepository.CreateUsuario(model);

                    if (nuevoId > 0)
                    {
                        TempData["Success"] = "Usuario registrado exitosamente.";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListUsuario");
                    }

                    TempData["Error"] = "Error al crear el usuario.";
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
        // EDITAR USUARIO
        // ==============
        [HttpGet]
        public async Task<IActionResult> EditUsuario(int id)
        {
            var usuario = await _crudUsuarioRepository.UsuarioId(id);

            if (usuario == null)
            {
                TempData["Error"] = "Usuario no encontrado.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListUsuario");
            }

            return View(usuario);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditUsuario(UsuarioViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudUsuarioRepository.ExisteEmailUsuario(model.email, model.id))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    bool resultado = await _crudUsuarioRepository.UpdateUsuario(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Usuario actualizado exitosamente.";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListUsuario");
                    }

                    TempData["Error"] = "Error al actualizar el usuario.";
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
        // ELIMINAR USUARIO
        // ================
        [HttpGet]
        public async Task<IActionResult> DeleteUsuario(int id)
        {
            var usuario = await _crudUsuarioRepository.UsuarioId(id);

            if (usuario == null)
            {
                TempData["Error"] = "Usuario no encontrado.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListUsuario");
            }

            return View(usuario);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                bool resultado = await _crudUsuarioRepository.DeleteUsuario(id);

                if (resultado)
                {
                    TempData["Success"] = "Usuario eliminado exitosamente.";
                    TempData["TipoMensaje"] = "success";
                }
                else
                {
                    TempData["Error"] = "Error al eliminar el usuario.";
                    TempData["TipoMensaje"] = "error";
                }
            }
            catch (Microsoft.Data.SqlClient.SqlException)
            {
                TempData["Error"] = "No se puede eliminar el usuario porque tiene información asociada.";
                TempData["TipoMensaje"] = "error";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListUsuario");
        }

        // ===================
        // RESETEAR CONTRASEÑA
        // ===================
        [HttpGet]
        public async Task<IActionResult> ResetPassword(int id)
        {
            var usuario = await _crudUsuarioRepository.UsuarioId(id);

            if (usuario == null)
            {
                TempData["Error"] = "Usuario no encontrado.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListUsuario");
            }

            return View(usuario);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(UsuarioViewModel model)
        {
            bool resultado = await _crudUsuarioRepository.ResetContrasenaUsuario(model.id);

            if (resultado)
            {
                TempData["Success"] = "Contraseña reseteada a '123456' exitosamente.";
                TempData["TipoMensaje"] = "success";
            }
            else
            {
                TempData["Error"] = "Error al resetear la contraseña.";
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListUsuario");
        }
    }
}
