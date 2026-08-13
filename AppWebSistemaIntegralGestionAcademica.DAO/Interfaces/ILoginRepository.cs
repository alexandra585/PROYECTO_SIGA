using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces
{
    public interface ILoginRepository
    {
        Task<Usuarios?> ValidarUsuario(string email, string password); // listo usp
    }
}
