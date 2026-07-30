using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class CRUDUsuarioRepository : AppBaseRepository, ICRUDUsuarioRepository
    {
        public CRUDUsuarioRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<List<UsuarioViewModel>> ListUsuario()
        {
            var usuarios = new List<UsuarioViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_Usuarios", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            usuarios.Add(new UsuarioViewModel
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                email = reader.GetString(reader.GetOrdinal("email")),
                                rol = reader.GetString(reader.GetOrdinal("rol")),
                                activo = reader.GetBoolean(reader.GetOrdinal("activo")),
                                fechaRegistro = reader.GetDateTime(reader.GetOrdinal("fechaRegistro")),
                                numeroIntentos = reader.GetInt32(reader.GetOrdinal("numeroIntentos")),
                                codigoEstudiante = reader.GetString(reader.GetOrdinal("CodigoEstudiante")),
                                especialidad = reader.GetString(reader.GetOrdinal("Especialidad"))
                            });
                        }
                    }
                }
            }
            return usuarios;
        }

        public async Task<UsuarioViewModel> UsuarioId(int id)
        {
            UsuarioViewModel usuario = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UsuarioId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            usuario = new UsuarioViewModel
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                email = reader.GetString(reader.GetOrdinal("email")),
                                rol = reader.GetString(reader.GetOrdinal("rol")),
                                activo = reader.GetBoolean(reader.GetOrdinal("activo")),
                                fechaRegistro = reader.GetDateTime(reader.GetOrdinal("fechaRegistro")),
                                numeroIntentos = reader.GetInt32(reader.GetOrdinal("numeroIntentos")),
                                codigoEstudiante = reader.GetString(reader.GetOrdinal("CodigoEstudiante")),
                                especialidad = reader.GetString(reader.GetOrdinal("Especialidad"))
                            };
                        }
                    }
                }
            }
            return usuario;
        }

        public async Task<int> CreateUsuario(UsuarioViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateUsuario", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    string contraseniaEncriptada = ContraseniaHelper.EncriptarContrasenia("123456");

                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@contrasenia", contraseniaEncriptada);
                    cmd.Parameters.AddWithValue("@rol", model.rol);
                    cmd.Parameters.AddWithValue("@activo", model.activo);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<bool> UpdateUsuario(UsuarioViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UpdateUsuario", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", model.id);
                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@activo", model.activo);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ResetContrasenaUsuario(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ResetContrasenaUsuario", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    string nuevaContrasenaHash = ContraseniaHelper.EncriptarContrasenia("123456");

                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@contrasenia", nuevaContrasenaHash);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> DeleteUsuario(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DeleteUsuario", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ExisteEmailUsuario(string email, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteEmailUsuario", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@idExcluir", (object?)idExcluir ?? DBNull.Value);

                    var result = await cmd.ExecuteScalarAsync();
                    int count = result != null ? Convert.ToInt32(result) : 0;

                    return count > 0;
                }
            }
        }
    }
}
