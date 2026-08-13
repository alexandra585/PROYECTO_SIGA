using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDDocenteRepository
    {
        Task<DocenteListadoViewModel> ListDocente(
            int pagina = 1,
            int tamanioPagina = 10,
            string? nombre = null,
            string? email = null,
            string? especialidad = null,
            string? gradoAcademico = null,
            bool? activo = true
        ); // listado con paginacion
        Task<DocenteViewModel> DocenteId(int id); // listo usp
        Task<int> CreateUsuarioDocente(DocenteViewModel model); // listo usp
        Task<bool> CreateDocente(int usuarioId, DocenteViewModel model); // listo usp
        Task<bool> UpdateDocente(DocenteViewModel model); // listo usp
        Task<bool> DeleteDocente(int id); // listo usp
        Task<bool> ExisteEmailDocente(string email, int? idExcluir = null); // listo usp
    }
}
