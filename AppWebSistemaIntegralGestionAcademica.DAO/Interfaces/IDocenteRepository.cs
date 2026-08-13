using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface IDocenteRepository
    {
        Task<DocenteDashboardViewModel> DocenteDashboard(int usuarioId); // listo usp
        Task<List<CursoDocenteViewModel>> CursosAsignadosDocente(int docenteId); // listo usp
        Task<List<CursoEstudianteViewModel>> CursosEstudiantesDocente(int cursoDocenteId); // listo usp
        Task<List<EvaluacionNotaViewModel>> CursosEvaluacionesDocente(int cursoDocenteId); // listo usp
        Task<bool> RegistrarNotas(int matriculaId, int evaluacionId, decimal nota, int docenteId, string observacion); // listo usp
        Task<bool> RegistrarAsistencias(int matriculaId, string estado, int docenteId, string observacion); // listo usp
        Task<List<NotaViewModel>> ObtenerNotasPorMatricula(int matriculaId); // listo usp
        Task<Dictionary<int, Dictionary<int, (decimal nota, string observacion)>>> ObtenerNotasExistentes(int cursoDocenteId); // listo usp
        Task<List<AsistenciaViewModel>> ObtenerAsistenciasPorCurso(int cursoDocenteId, DateTime? fecha = null); // listo usp
        Task<ReporteCursoViewModel> ObtenerReporteCurso(int cursoDocenteId); // listo usp
    }
}