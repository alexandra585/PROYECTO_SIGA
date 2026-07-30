
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDApoderadoRepository
    {
        Task<List<ApoderadoViewModel>> ListApoderado(); // listo usp
        Task<ApoderadoViewModel> ApoderadoId(int id); // listo usp
        Task<int> CreateUsuarioApoderado(ApoderadoViewModel model);  // listo usp
        Task<bool> CreateApoderado(int id, ApoderadoViewModel model);  // listo usp
        Task<bool> UpdateApoderado(ApoderadoViewModel model);  // listo usp
        Task<bool> DeleteApoderado(int id);  // listo usp
        Task<bool> ExisteEmailApoderado(string email, int? idExcluir = null);  // listo usp
        Task<bool> ExisteDniApoderado(string dni, int? idExcluir = null);  // listo usp
    }
}
