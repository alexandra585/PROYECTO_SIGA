using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface IApoderadoRepository
    {
        Task<ApoderadoDashboardViewModel> ApoderadoDashboard(int apoderadoId); // listo usp
        Task<List<ApoderadoHijoViewModel>> ListHijos(int apoderadoId); // listo usp
        Task<List<PeriodoAcademico>> ListPeriodos(); // listo usp
        Task<ApoderadoLibretaViewModel> LibretaNotas(int apoderadoId, int estudianteId, int? periodoId); // listo usp
    }
}
