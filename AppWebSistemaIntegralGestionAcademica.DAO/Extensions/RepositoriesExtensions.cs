using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories;
using Microsoft.Extensions.DependencyInjection;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Extensions
{
    public static class RepositoriesExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<ILoginRepository, LoginRepository>();
            services.AddScoped<IDirectorRepository, DirectorRepository>();
            services.AddScoped<ISecretariaRepository, SecretariaRepository>();
            services.AddScoped<IDocenteRepository, DocenteRepository>();
            services.AddScoped<IEstudianteRepository, EstudianteRepository>();
            services.AddScoped<IApoderadoRepository, ApoderadoRepository>();
            services.AddScoped<ICRUDUsuarioRepository, CRUDUsuarioRepository>();
            services.AddScoped<ICRUDSecretariaRepository, CRUDSecretariaRepository>();
            services.AddScoped<ICRUDDocenteRepository, CRUDDocenteRepository>();
            services.AddScoped<ICRUDEstudianteRepository, CRUDEstudianteRepository>();
            services.AddScoped<ICRUDApoderadoRepository, CRUDApoderadoRepository>();
            services.AddScoped<ICRUDCursoRepository, CRUDCursoRepository>();
            services.AddScoped<IChatRepository, ChatRepository>();

            return services;
        }
    }
}
