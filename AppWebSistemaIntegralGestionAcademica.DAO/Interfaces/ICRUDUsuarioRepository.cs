using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDUsuarioRepository
    {
        Task<UsuarioListadoViewModel> ListUsuario(
            int pagina = 1,
            int tamanioPagina = 10,
            string? nombre = null,
            string? email = null,
            string? rol = null,
            bool? activo = null
        );  // lista con paginacion
        Task<UsuarioViewModel> UsuarioId(int id); // listo usp
        Task<int> CreateUsuario(UsuarioViewModel model); // listo usp
        Task<bool> UpdateUsuario(UsuarioViewModel model); // listo usp
        Task<bool> DeleteUsuario(int id); // listo usp
        Task<bool> ExisteEmailUsuario(string email, int? idExcluir = null); // listo usp
        Task<bool> ResetContrasenaUsuario(int id); // listo usp
    }
}