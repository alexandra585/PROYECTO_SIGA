using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class LoginRepository : AppBaseRepository, ILoginRepository
    {
        public LoginRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<Usuarios?> ValidarUsuario(string email, string password)
        {
            Usuarios? usuarios = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ValidarUsuario", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@email", email);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            string storedHash = reader.GetFieldValue<string>(reader.GetOrdinal("contrasenia"));
                            bool activo = reader.GetFieldValue<bool>(reader.GetOrdinal("activo"));
                            string rolBD = reader.GetFieldValue<string>(reader.GetOrdinal("rol"));

                            if (ContraseniaHelper.VerificarContrasenia(password, storedHash) && activo)
                            {
                                usuarios = new Usuarios
                                {
                                    id = reader.GetFieldValue<int>(reader.GetOrdinal("id")),
                                    nombreCompleto = reader.GetFieldValue<string>(reader.GetOrdinal("nombreCompleto")),
                                    email = reader.GetFieldValue<string>(reader.GetOrdinal("email")),
                                    contrasenia = storedHash,
                                    rol = rolBD,
                                    activo = activo,
                                    numeroIntentos = reader.GetFieldValue<int>(reader.GetOrdinal("numeroIntentos"))
                                };
                            }
                        }
                    }
                }
            }
            return usuarios;
        }
    }
}
