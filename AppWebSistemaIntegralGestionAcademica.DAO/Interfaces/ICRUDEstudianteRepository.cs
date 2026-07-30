using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDEstudianteRepository
    {
        Task<List<EstudianteViewModel>> ListEstudiante(); // listo usp
        Task<EstudianteViewModel> EstudianteId(int id); // listo usp
        Task<int> CreateUsuarioEstudiante(EstudianteViewModel model); // listo usp
        Task<bool> CreateEstudiante(int usuarioId, EstudianteViewModel model); // listo usp
        Task<bool> UpdateEstudiante(EstudianteViewModel model); // listo usp
        Task<bool> DeleteEstudiante(int id); // listo usp
        Task<bool> ExisteCodigoEstudiante(string codigo, int? idExcluir = null); // listo usp
        Task<bool> ExisteEmailEstudiante(string email, int? idExcluir = null); // listo usp
    }
}
