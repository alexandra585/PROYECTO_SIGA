using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ISecretariaRepository
    {
        Task<SecretariaDashboardViewModel> SecretariaDashboard(); // listo usp

        Task<bool> AsignarCursoDocente(int docenteId, int cursoId, int periodoId); // listo usp
        Task<AsignacionCursoDocenteViewModel> AsignacionCursoDocenteViewModel(); // listo usp
        Task<List<AsignacionCursoDocenteVM>> ListAsignacionCursoDocenteViewModel(); // listo usp
        Task<int> DesasignarCursoDocenteViewModel(int id); // listo usp

        Task<bool> AsignarCursoEstudiante(int estudianteId, int cursoDocenteId); // listo usp
        Task<AsignacionCursoEstudianteViewModel> AsignacionCursoEstudianteViewModel(); // listo usp
        Task<List<AsignacionCursoEstudianteVM>> ListAsignacionCursoEstudianteViewModel(); // listo usp
        Task<int> DesasignarCursoEstudianteViewModel(int id); // listo usp

        Task<int> AsignarApoderadoEstudiante(int apoderadoId, int estudianteId, string parentesco, string? parentescoDetalle); // listo usp
        Task<AsignacionApoderadoEstudianteViewModel> AsignacionApoderadoEstudianteViewModel(); // listo usp (list apoderados activos + list estudiantes)
        Task<List<ApoderadoAsignacionGrupoVM>> ListAsignacionApoderadoEstudianteViewModel(); // listo usp
        Task<int> DesasignarApoderadoEstudianteViewModel(int id); // listo usp
    }
}
