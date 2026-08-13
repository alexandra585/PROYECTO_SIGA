using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface IChatRepository
    {
        Task<MensajesApoderadoViewModel> ListarChatDocenteApoderado(int apoderadoId); // listo usp
        Task<MensajesDocenteViewModel> ListarChatApoderadoDocente(int docenteId); // listo usp
        Task<int> ObtenerCrearChatConversacion(int apoderadoId, int docenteId, int? cursoId = null); // listo usp
        Task<ChatConversacionViewModel> ObtenerChatConversacion(int conversacionId, int usuarioActualId); // listo usp
        Task<ChatMensajeViewModel> EnviarChatMensaje(int conversacionId, int remitenteId, string contenido); // listo usp
        Task MarcarChatComoLeido(int conversacionId, int usuarioId); // listo usp
        Task EliminarChat(int conversacionId, int usuarioId); // listo usp
        Task VaciarChat(int conversacionId, int usuarioId); // listo usp
    }
}
