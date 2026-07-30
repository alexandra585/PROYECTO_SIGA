using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDCursoRepository
    {
        Task<List<CursoViewModel>> ListCurso(); // listo usp
        Task<CursoViewModel> CursoId(int id); // listo usp
        Task<bool> CreateCurso(CursoViewModel model); // listo usp
        Task<bool> UpdateCurso(CursoViewModel model); // listo usp
        Task<bool> DeleteCurso(int id); // listo usp
        Task<bool> ExisteCodigoCurso(string codigoCurso, int? idExcluir = null); // listo usp
    }
}