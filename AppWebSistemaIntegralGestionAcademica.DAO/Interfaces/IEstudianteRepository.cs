using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface IEstudianteRepository
    {
        Task<EstudianteDashboardViewModel> EstudianteDashboard(int usuarioId); // listo usp
        Task<List<CursoEstudianteNotaViewModel>> MisCursos(int estudianteId); // listo usp
        Task<List<NotaDetalleViewModel>> MisNotasCursos(int matriculaId); // listo usp
        Task<List<ResumenNotaViewModel>> ResumenNotas(int estudianteId); // listo usp
        Task<List<AsistenciaEstudianteViewModel>> MisAsistencias(int estudianteId); // listo usp
        Task<ReporteAcademicoViewModel> ReporteAcademico(int estudianteId); // listo usp
    }
}