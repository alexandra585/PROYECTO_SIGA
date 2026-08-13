using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ICRUDSecretariaRepository
    {
        Task<SecretariaListadoViewModel> ListSecretaria(
            int pagina = 1,
            int tamanioPagina = 10,
            string? nombre = null,
            string? email = null,
            string? cargo = null,
            string? telefono = null,
            bool? activo = true
        ); // listado con paginado
        Task<SecretariaViewModel> SecretariaId(int id); // listo usp
        Task<int> CreateUsuarioSecretaria(SecretariaViewModel model); // listo usp
        Task<bool> CreateSecretaria(int id, SecretariaViewModel model); // listo usp
        Task<bool> UpdateSecretaria(SecretariaViewModel model); // listo usp
        Task<bool> DeleteSecretaria(int id); // listo usp
        Task<bool> ExisteEmailSecretaria(string email, int? idExcluir = null); // listo usp
        Task<List<UsuarioViewModel>> BuscarUsuarioDisponibleSecretaria(string filtro); // listo usp
        Task<bool> ActualizarRolUsuarioSecretaria(int id, string rol); // listo usp
    }
}
