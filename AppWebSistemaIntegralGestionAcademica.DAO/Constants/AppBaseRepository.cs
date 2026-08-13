using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants
{
    public class AppBaseRepository
    {
        private readonly string _connectionString;

        protected AppBaseRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString(AppConstants.ConnectionStringName) ?? throw new ArgumentNullException(
               AppConstants.ConnectionStringName,
               $"La cadena de conexión '{AppConstants.ConnectionStringName}' no está configurada correctamente en appsettings.json"
           );
        }

        protected SqlConnection GetConnection()
        {
            return new SqlConnection(_connectionString);
        }
    }
}
