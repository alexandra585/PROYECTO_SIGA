using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface IDirectorRepository
    {
        Task<DirectorDashboardViewModel> DirectorDashboard(); // listo usp
        Task<List<PeriodoAcademico>> PeriodoAcademico(); // listo usp
        Task<List<CursoDocenteEstudiante>> CursoDocente(); // listo usp
    }
}