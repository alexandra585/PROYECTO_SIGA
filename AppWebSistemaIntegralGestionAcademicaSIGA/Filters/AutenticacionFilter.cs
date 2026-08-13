using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false)]
    public class AutorizationRoleFilter : Attribute, IAsyncActionFilter
    {
        private readonly string[] _rolesPermitidos;

        public AutorizationRoleFilter(params string[] rolesPermitidos)
        {
            _rolesPermitidos = rolesPermitidos ?? Array.Empty<string>();
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            var usuarioId = context.HttpContext.Session.GetString("UsuarioId");

            if (string.IsNullOrEmpty(usuarioId))
            {
                context.Result = new RedirectToActionResult(
                    "IniciarSesion",
                    "Auth",
                    null);
                return;
            }

            var rol = context.HttpContext.Session.GetString("Rol");

            if (!_rolesPermitidos.Contains(rol))
            {
                switch (rol)
                {
                    case "Director":
                        context.Result = new RedirectToActionResult("Dashboard", "Director", null);
                        break;
                    case "Secretaria":
                        context.Result = new RedirectToActionResult("Dashboard", "Secretaria", null);
                        break;
                    case "Docente":
                        context.Result = new RedirectToActionResult("Dashboard", "Docente", null);
                        break;
                    case "Estudiante":
                        context.Result = new RedirectToActionResult("Dashboard", "Estudiante", null);
                        break;
                    case "Apoderado":
                        context.Result = new RedirectToActionResult("Dashboard", "Apoderado", null);
                        break;
                    default:
                        context.Result = new RedirectToActionResult("IniciarSesion", "Auth", null);
                        break;
                }
            }

            await next();
        }
    }
}