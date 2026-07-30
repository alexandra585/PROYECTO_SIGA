using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class CRUDEstudianteRepository : AppBaseRepository , ICRUDEstudianteRepository
    {
        public CRUDEstudianteRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<List<EstudianteViewModel>> ListEstudiante()
        {
            var estudiantes = new List<EstudianteViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_Estudiantes", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            estudiantes.Add(new EstudianteViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombreCompleto = reader["nombreCompleto"].ToString(),
                                email = reader["email"].ToString(),
                                codigoEstudiante = reader["codigoEstudiante"].ToString(),
                                nombreCarrera = reader["nombreCarrera"].ToString(),
                                semestreActual = Convert.ToInt32(reader["semestreActual"]),
                                activo = Convert.ToBoolean(reader["activo"]),
                                fechaRegistro = Convert.ToDateTime(reader["fechaRegistro"])
                            });
                        }
                    }
                }
            }
            return estudiantes;
        }

        public async Task<EstudianteViewModel> EstudianteId(int id)
        {
            EstudianteViewModel estudiante = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_EstudianteId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            estudiante = new EstudianteViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombreCompleto = reader["nombreCompleto"].ToString(),
                                email = reader["email"].ToString(),
                                codigoEstudiante = reader["codigoEstudiante"].ToString(),
                                nombreCarrera = reader["nombreCarrera"].ToString(),
                                semestreActual = Convert.ToInt32(reader["semestreActual"]),
                                activo = Convert.ToBoolean(reader["activo"]),
                                fechaRegistro = Convert.ToDateTime(reader["fechaRegistro"])
                            };
                        }
                    }
                }
            }
            return estudiante;
        }

        public async Task<int> CreateUsuarioEstudiante(EstudianteViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateUsuarioEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@contrasenia", ContraseniaHelper.EncriptarContrasenia("123456"));
                    cmd.Parameters.AddWithValue("@activo", model.activo);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<bool> CreateEstudiante(int usuarioId, EstudianteViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", usuarioId);
                    cmd.Parameters.AddWithValue("@codigoEstudiante", model.codigoEstudiante);
                    cmd.Parameters.AddWithValue("@nombreCarrera", model.nombreCarrera);
                    cmd.Parameters.AddWithValue("@semestreActual", model.semestreActual);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> UpdateEstudiante(EstudianteViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UpdateEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", model.id);
                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@activo", model.activo);
                    cmd.Parameters.AddWithValue("@codigoEstudiante", model.codigoEstudiante);
                    cmd.Parameters.AddWithValue("@nombreCarrera", model.nombreCarrera);
                    cmd.Parameters.AddWithValue("@semestreActual", model.semestreActual);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> DeleteEstudiante(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DeleteEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ExisteCodigoEstudiante(string codigoEstudiante, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteCodigoEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@codigoEstudiante", codigoEstudiante);
                    cmd.Parameters.AddWithValue("@idExcluir", (object?)idExcluir ?? DBNull.Value);

                    var result = await cmd.ExecuteScalarAsync();
                    int count = result != null ? Convert.ToInt32(result) : 0;

                    return count > 0;
                }
            }
        }

        public async Task<bool> ExisteEmailEstudiante(string email, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteEmailEstudiante", conn))
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
