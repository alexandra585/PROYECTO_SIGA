using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using Microsoft.AspNetCore.SignalR;
using System.Collections.Concurrent;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Hubs
{
    public class ChatHub : Hub
    {
        private readonly IChatRepository _chatRepository;
        private static readonly ConcurrentDictionary<int, HashSet<string>> _conexiones = new();
        private static readonly ConcurrentDictionary<string, int> _connectionUser = new();

        public ChatHub(IChatRepository chatRepository)
        {
            _chatRepository = chatRepository;
        }

        private int? GetUsuarioId()
        {
            if (_connectionUser.TryGetValue(Context.ConnectionId, out var id))
                return id;
            return null;
        }

        // ========
        // CONEXIÓN
        // ========
        public override async Task OnConnectedAsync()
        {
            var httpContext = Context.GetHttpContext();
            if (httpContext == null)
            {
                Context.Abort();
                return;
            }

            var usuarioId = httpContext.Session.GetInt32("UsuarioId");
            var nombre = httpContext.Session.GetString("NombreUsuario") ?? "Usuario";
            var rol = httpContext.Session.GetString("Rol");

            if (usuarioId == null || string.IsNullOrEmpty(rol))
            {
                Context.Abort();
                return;
            }

            _connectionUser[Context.ConnectionId] = usuarioId.Value;

            _conexiones.AddOrUpdate(
                usuarioId.Value,
                _ => new HashSet<string> { Context.ConnectionId },
                (_, set) =>
                {
                    lock (set) { set.Add(Context.ConnectionId); }
                    return set;
                });

            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{usuarioId.Value}");
            await Clients.Others.SendAsync("UsuarioEnLinea", usuarioId.Value, nombre);
            await base.OnConnectedAsync();
        }

        // ===========
        // DESCONEXIÓN
        // ===========
        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            if (_connectionUser.TryRemove(Context.ConnectionId, out var usuarioId))
            {
                if (_conexiones.TryGetValue(usuarioId, out var set))
                {
                    lock (set)
                    {
                        set.Remove(Context.ConnectionId);
                        if (set.Count == 0)
                        {
                            _conexiones.TryRemove(usuarioId, out _);
                            _ = Clients.Others.SendAsync("UsuarioDesconectado", usuarioId);
                        }
                    }
                }
            }

            await base.OnDisconnectedAsync(exception);
        }

        // =========================
        // UNIRSE A UNA CONVERSACIÓN
        // =========================
        public async Task UnirseConversacion(int conversacionId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"conv_{conversacionId}");
        }

        // =========================
        // SALIR DE UNA CONVERSACIÓN
        // =========================
        public async Task SalirConversacion(int conversacionId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"conv_{conversacionId}");
        }

        // ==============
        // ENVIAR MENSAJE
        // ==============
        public async Task EnviarMensaje(int conversacionId, string contenido)
        {
            if (string.IsNullOrWhiteSpace(contenido) || contenido.Length > 3000)
                return;

            var remitenteId = GetUsuarioId();
            if (remitenteId == null)
                return;

            var mensaje = await _chatRepository.EnviarChatMensaje(
                conversacionId, remitenteId.Value, contenido.Trim());

            await Clients.Group($"conv_{conversacionId}").SendAsync("RecibirMensaje", mensaje);
            await Clients.Group($"conv_{conversacionId}")
                .SendAsync("ActualizarUltimoMensaje", conversacionId, mensaje.Contenido, mensaje.FechaEnvio);
        }

        // =================
        // MARCAR COMO LEÍDO
        // =================
        public async Task MarcarComoLeido(int conversacionId)
        {
            var usuarioId = GetUsuarioId();
            if (usuarioId == null)
                return;

            try
            {
                await _chatRepository.MarcarChatComoLeido(conversacionId, usuarioId.Value);
                await Clients.OthersInGroup($"conv_{conversacionId}").SendAsync("MensajesLeidos", conversacionId, usuarioId.Value);
            }
            catch
            {
            }
        }

        // =============
        // ELIMINAR CHAT
        // =============
        public async Task EliminarChat(int conversacionId)
        {
            var usuarioId = GetUsuarioId();
            if (usuarioId == null)
                return;

            await _chatRepository.EliminarChat(conversacionId, usuarioId.Value);
            await Clients.Caller.SendAsync("ChatEliminado", conversacionId);
        }

        // ===========
        // VACIAR CHAT
        // ===========
        public async Task VaciarChat(int conversacionId)
        {
            var usuarioId = GetUsuarioId();
            if (usuarioId == null)
                return;

            await _chatRepository.VaciarChat(conversacionId, usuarioId.Value);
            await Clients.Caller.SendAsync("ChatVaciado", conversacionId);
        }

        // ====================
        // PRESENCIA (EN LÍNEA)
        // ====================
        public Task<List<int>> ObtenerUsuariosEnLinea()
        {
            return Task.FromResult(_conexiones.Keys.ToList());
        }

        public static bool EstaEnLinea(int usuarioId)
        {
            return _conexiones.ContainsKey(usuarioId);
        }

        public static List<int> ObtenerIdsEnLinea()
        {
            return _conexiones.Keys.ToList();
        }
    }
}
