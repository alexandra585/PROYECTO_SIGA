using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Director")]
    public class CRUDEstudianteController : Controller
    {
        private readonly ICRUDEstudianteRepository _crudEstudianteRepository;

        public CRUDEstudianteController(ICRUDEstudianteRepository crudEstudianteRepository)
        {
            _crudEstudianteRepository = crudEstudianteRepository;
        }

        // ==================
        // LISTAR ESTUDIANTES
        // ==================
        [HttpGet]
        public async Task<IActionResult> ListEstudiante()
        {
            var estudiantes = await _crudEstudianteRepository.ListEstudiante();
            return View(estudiantes);
        }

        // ================
        // CREAR ESTUDIANTE
        // ================
        [HttpGet]
        public IActionResult CreateEstudiante()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateEstudiante(EstudianteViewModel model)
        {
            bool esUsuarioExistente = model.id > 0;

            if (ModelState.IsValid)
            {
                try
                {
                    if (esUsuarioExistente)
                    {
                        // =========================================
                        // MODO 1: Usuario ya existente seleccionado
                        // =========================================
                        if (await _crudEstudianteRepository.ExisteCodigoEstudiante(model.codigoEstudiante))
                        {
                            ModelState.AddModelError("codigoEstudiante", "El código de estudiante ya existe");
                            return View(model);
                        }

                        bool resultado = await _crudEstudianteRepository.CreateEstudiante(model.id, model);

                        if (resultado)
                        {
                            await _crudEstudianteRepository.ActualizarRolUsuarioEstudiante(model.id, "Estudiante");

                            TempData["Success"] = "Estudiante registrado exitosamente.";
                            TempData["TipoMensaje"] = "success";
                            return RedirectToAction("ListEstudiante");
                        }

                        TempData["Error"] = "Error al registrar el estudiante.";
                        TempData["TipoMensaje"] = "error";
                    }
                    else
                    {
                        // ========================================
                        // MODO 2: Crear usuario nuevo + estudiante
                        // ========================================
                        if (string.IsNullOrWhiteSpace(model.nombreCompleto))
                        {
                            ModelState.AddModelError("nombreCompleto", "El nombre completo es obligatorio");
                            return View(model);
                        }

                        if (string.IsNullOrWhiteSpace(model.email))
                        {
                            ModelState.AddModelError("email", "El correo electrónico es obligatorio");
                            return View(model);
                        }

                        if (await _crudEstudianteRepository.ExisteCodigoEstudiante(model.codigoEstudiante))
                        {
                            ModelState.AddModelError("codigoEstudiante", "El código de estudiante ya existe");
                            return View(model);
                        }

                        if (await _crudEstudianteRepository.ExisteEmailEstudiante(model.email))
                        {
                            ModelState.AddModelError("email", "El email ya está registrado");
                            return View(model);
                        }

                        int nuevoId = await _crudEstudianteRepository.CreateUsuarioEstudiante(model);

                        if (nuevoId > 0)
                        {
                            bool resultado = await _crudEstudianteRepository.CreateEstudiante(nuevoId, model);

                            if (resultado)
                            {
                                TempData["Success"] = "Estudiante registrado exitosamente.";
                                TempData["TipoMensaje"] = "success";
                                return RedirectToAction("ListEstudiante");
                            }
                        }

                        TempData["Error"] = "Error al crear el estudiante.";
                        TempData["TipoMensaje"] = "error";
                    }
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
        // EDITAR ESTUDIANTE
        // =================
        [HttpGet]
        public async Task<IActionResult> EditEstudiante(int id)
        {
            var estudiante = await _crudEstudianteRepository.EstudianteId(id);

            if (estudiante == null)
            {
                TempData["Error"] = "Estudiante no encontrado.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListEstudiante");
            }

            return View(estudiante);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditEstudiante(EstudianteViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (await _crudEstudianteRepository.ExisteCodigoEstudiante(model.codigoEstudiante, model.id))
                    {
                        ModelState.AddModelError("codigoEstudiante", "El código de estudiante ya existe");
                        return View(model);
                    }

                    if (await _crudEstudianteRepository.ExisteEmailEstudiante(model.email, model.id))
                    {
                        ModelState.AddModelError("email", "El email ya está registrado");
                        return View(model);
                    }

                    bool resultado = await _crudEstudianteRepository.UpdateEstudiante(model);

                    if (resultado)
                    {
                        TempData["Success"] = "Estudiante actualizado exitosamente.";
                        TempData["TipoMensaje"] = "success";
                        return RedirectToAction("ListEstudiante");
                    }

                    TempData["Error"] = "Error al actualizar el estudiante.";
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
        // ELIMINAR ESTUDIANTE
        // ===================
        [HttpGet]
        public async Task<IActionResult> DeleteEstudiante(int id)
        {
            var estudiante = await _crudEstudianteRepository.EstudianteId(id);

            if (estudiante == null)
            {
                TempData["Error"] = "Estudiante no encontrado.";
                TempData["TipoMensaje"] = "error";
                return RedirectToAction("ListEstudiante");
            }

            return View(estudiante);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                bool resultado = await _crudEstudianteRepository.DeleteEstudiante(id);

                if (resultado)
                {
                    TempData["Success"] = "Estudiante eliminado exitosamente.";
                    TempData["TipoMensaje"] = "success";
                }
                else
                {
                    TempData["Error"] = "Error al eliminar el estudiante.";
                    TempData["TipoMensaje"] = "error";
                }
            }
            catch (Microsoft.Data.SqlClient.SqlException)
            {
                TempData["Error"] = "No se puede eliminar el estudiante porque tiene matrículas asociadas.";
                TempData["TipoMensaje"] = "error";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
                TempData["TipoMensaje"] = "error";
            }

            return RedirectToAction("ListEstudiante");
        }

        // =============================
        // BUSCAR USUARIOS - ESTUDIANTES
        // =============================
        [HttpGet]
        public async Task<IActionResult> BuscarUsuarioDisponibleEstudiante(string? filtro)
        {
            var usuarios = await _crudEstudianteRepository.BuscarUsuarioDisponibleEstudiante(filtro);
            return Json(usuarios);
        }
    }
}
