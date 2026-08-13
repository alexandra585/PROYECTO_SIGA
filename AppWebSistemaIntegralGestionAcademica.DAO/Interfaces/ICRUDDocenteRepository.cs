using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDDocenteRepository
    {
        Task<List<DocenteViewModel>> ListDocente(); // listo usp
        Task<DocenteViewModel> DocenteId(int id); // listo usp
        Task<int> CreateUsuarioDocente(DocenteViewModel model); // listo usp
        Task<bool> CreateDocente(int usuarioId, DocenteViewModel model); // listo usp
        Task<bool> UpdateDocente(DocenteViewModel model); // listo usp
        Task<bool> DeleteDocente(int id); // listo usp
        Task<bool> ExisteEmailDocente(string email, int? idExcluir = null); // listo usp
        Task<List<UsuarioViewModel>> BuscarUsuarioDisponibleDocente(string? filtro); // listo usp
        Task<bool> ActualizarRolUsuarioDocente(int id, string rol); // listo usp
    }
}
