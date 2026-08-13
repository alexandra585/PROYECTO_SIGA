
namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class ChatDocenteViewModel
    {
        public int DocenteId { get; set; }
        public string NombreCompleto { get; set; } = string.Empty;
        public string? Especialidad { get; set; }
        public string? CursosRelacionados { get; set; }
        public int? ConversacionId { get; set; }
        public string? UltimoMensaje { get; set; }
        public DateTime? UltimoMensajeFecha { get; set; }
        public int MensajesNoLeidos { get; set; }
        public bool EnLinea { get; set; }
    }

    public class ChatApoderadoViewModel
    {
        public int ApoderadoId { get; set; }
        public string NombreCompleto { get; set; } = string.Empty;
        public string? HijosRelacionados { get; set; }
        public int? ConversacionId { get; set; }
        public string? UltimoMensaje { get; set; }
        public DateTime? UltimoMensajeFecha { get; set; }
        public int MensajesNoLeidos { get; set; }
        public bool EnLinea { get; set; }
    }

    public class ChatMensajeViewModel
    {
        public long Id { get; set; }
        public int ConversacionId { get; set; }
        public int RemitenteId { get; set; }
        public string NombreRemitente { get; set; } = string.Empty;
        public string Contenido { get; set; } = string.Empty;
        public DateTime FechaEnvio { get; set; }
        public bool Leido { get; set; }
        public bool EsMio { get; set; }
    }

    public class ChatConversacionViewModel
    {
        public int ConversacionId { get; set; }
        public int ApoderadoId { get; set; }
        public int DocenteId { get; set; }
        public string NombreDocente { get; set; } = string.Empty;
        public string NombreApoderado { get; set; } = string.Empty;
        public string? EspecialidadDocente { get; set; }
        public bool DocenteEnLinea { get; set; }
        public List<ChatMensajeViewModel> Mensajes { get; set; } = new();
    }

    public class MensajesApoderadoViewModel
    {
        public int ApoderadoId { get; set; }
        public string NombreApoderado { get; set; } = string.Empty;
        public List<ChatDocenteViewModel> Docentes { get; set; } = new();
    }

    public class MensajesDocenteViewModel
    {
        public int DocenteId { get; set; }
        public string NombreDocente { get; set; } = string.Empty;
        public List<ChatApoderadoViewModel> Apoderados { get; set; } = new();
    }
}
