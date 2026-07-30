using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Extensions
{
    public static class DatabaseContextExtensions
    {
        public static IServiceCollection AddDatabaseContext(this IServiceCollection services, IConfiguration configuration)
        {
            var connectionString = configuration.GetConnectionString(AppConstants.ConnectionStringName)
                ?? throw new InvalidOperationException($"La cadena de conexión '{AppConstants.ConnectionStringName}' no está configurada correctamente en appsettings.json");

            services.AddDbContext<AppDatabaseContext>(options =>
                options.UseSqlServer(connectionString));

            return services;
        }
    }
}
