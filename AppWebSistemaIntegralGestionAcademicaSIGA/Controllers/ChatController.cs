using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Hubs;
using Microsoft.AspNetCore.Mvc;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Apoderado", "Docente")]
    public class ChatController : Controller
    {
        private readonly IChatRepository _chatRepository;

        public ChatController(IChatRepository chatRepository)
        {
            _chatRepository = chatRepository;
        }

        // ===========================
        // VISTA PRINCIPAL DE MENSAJES
        // ===========================
        [HttpGet]
        public async Task<IActionResult> Mensajes()
        {
            int? usuarioId = HttpContext.Session.GetInt32("UsuarioId");
            string? rol = HttpContext.Session.GetString("Rol");

            if (usuarioId == null)
            {
                return RedirectToAction("IniciarSesion", "Auth");
            }

            if (rol == "Apoderado")
            {
                var model = await _chatRepository.ListarChatDocenteApoderado(usuarioId.Value);
                foreach (var docente in model.Docentes)
                {
                    docente.EnLinea = ChatHub.EstaEnLinea(docente.DocenteId);
                }
                return View("MensajesApoderado", model);
            }

            if (rol == "Docente")
            {
                var model = await _chatRepository.ListarChatApoderadoDocente(usuarioId.Value);
                foreach (var apoderado in model.Apoderados)
                {
                    apoderado.EnLinea = ChatHub.EstaEnLinea(apoderado.ApoderadoId);
                }
                return View("MensajesDocente", model);
            }

            return RedirectToAction("IniciarSesion", "Auth");
        }

        // ========================================
        // OBTENER O CREAR CONVERSACIÓN + HISTORIAL
        // ========================================
        [HttpGet]
        public async Task<IActionResult> ObtenerConversacionApoderado(int docenteId, int? conversacionId = null, int? cursoId = null)
        {
            int? apoderadoId = HttpContext.Session.GetInt32("UsuarioId");
            string? rol = HttpContext.Session.GetString("Rol");

            if (apoderadoId == null || rol != "Apoderado")
            {
                return Unauthorized();
            }

            if (docenteId <= 0)
            {
                return BadRequest(new { mensaje = "Docente inválido." });
            }

            try
            {
                int idConversacion;

                if (conversacionId.HasValue && conversacionId.Value > 0)
                {
                    idConversacion = conversacionId.Value;
                }
                else
                {
                    idConversacion = await _chatRepository.ObtenerCrearChatConversacion(apoderadoId.Value, docenteId, cursoId);
                }

                var conversacion = await _chatRepository.ObtenerChatConversacion(idConversacion, apoderadoId.Value);
                conversacion.DocenteEnLinea = ChatHub.EstaEnLinea(docenteId);
                return Json(conversacion);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    mensaje = "Error al cargar la conversación.",
                    detalle = ex.Message
                });
            }
        }

        [HttpGet]
        public async Task<IActionResult> ObtenerConversacionDocente(int apoderadoId, int? conversacionId = null)
        {
            int? docenteId = HttpContext.Session.GetInt32("UsuarioId");
            string? rol = HttpContext.Session.GetString("Rol");

            if (docenteId == null || rol != "Docente")
            {
                return Unauthorized();
            }

            if (apoderadoId <= 0)
            {
                return BadRequest(new { mensaje = "Apoderado inválido." });
            }

            try
            {
                int idConversacion;

                if (conversacionId.HasValue && conversacionId.Value > 0)
                {
                    idConversacion = conversacionId.Value;
                }
                else
                {
                    idConversacion = await _chatRepository.ObtenerCrearChatConversacion(apoderadoId, docenteId.Value, null);
                }

                var conversacion = await _chatRepository.ObtenerChatConversacion(idConversacion, docenteId.Value);
                conversacion.DocenteEnLinea = ChatHub.EstaEnLinea(apoderadoId);
                return Json(conversacion);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    mensaje = "Error al cargar la conversación.",
                    detalle = ex.Message
                });
            }
        }

        // =============
        // ELIMINAR CHAT
        // =============
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EliminarChat(int conversacionId)
        {
            int? usuarioId = HttpContext.Session.GetInt32("UsuarioId");
            if (usuarioId == null)
            {
                return Unauthorized();
            }

            if (conversacionId <= 0)
            {
                return BadRequest();
            }

            await _chatRepository.EliminarChat(conversacionId, usuarioId.Value);
            return Ok(new { ok = true });
        }

        // ===========
        // VACIAR CHAT
        // ===========
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> VaciarChat(int conversacionId)
        {
            int? usuarioId = HttpContext.Session.GetInt32("UsuarioId");
            if (usuarioId == null)
            {
                return Unauthorized();
            }

            if (conversacionId <= 0)
            {
                return BadRequest();
            }

            await _chatRepository.VaciarChat(conversacionId, usuarioId.Value);
            return Ok(new { ok = true });
        }

        // ==========================
        // LISTA DE USUARIOS EN LÍNEA
        // ==========================
        [HttpGet]
        public IActionResult UsuariosEnLinea()
        {
            int? usuarioId = HttpContext.Session.GetInt32("UsuarioId");
            if (usuarioId == null)
            {
                return Unauthorized();
            }

            var ids = ChatHub.ObtenerIdsEnLinea();
            return Json(new { usuarios = ids });
        }
    }
}
