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

        public async Task<EstudianteListadoViewModel> ListEstudiante(
            int pagina = 1,
            int tamanioPagina = 10,
            string? nombre = null,
            string? email = null,
            string? codigoEstudiante = null,
            string? nombreCarrera = null,
            int? semestreActual = null,
            bool? activo = true)
        {
            var resultado = new EstudianteListadoViewModel();

            // ==========================================
            // CONFIGURAR PAGINACIÓN
            // ==========================================

            resultado.Paginacion.Pagina = pagina;
            resultado.Paginacion.TamanioPagina = tamanioPagina;


            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand(
                    "usp_EstudiantesPaginado",
                    conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ==========================================
                    // PARÁMETROS DE PAGINACIÓN
                    // ==========================================

                    cmd.Parameters.AddWithValue(
                        "@Pagina",
                        pagina
                    );

                    cmd.Parameters.AddWithValue(
                        "@TamanioPagina",
                        tamanioPagina
                    );


                    // ==========================================
                    // PARÁMETROS DE FILTROS
                    // ==========================================

                    cmd.Parameters.AddWithValue(
                        "@Nombre",
                        string.IsNullOrWhiteSpace(nombre)
                            ? DBNull.Value
                            : nombre
                    );

                    cmd.Parameters.AddWithValue(
                        "@Email",
                        string.IsNullOrWhiteSpace(email)
                            ? DBNull.Value
                            : email
                    );

                    cmd.Parameters.AddWithValue(
                        "@CodigoEstudiante",
                        string.IsNullOrWhiteSpace(codigoEstudiante)
                            ? DBNull.Value
                            : codigoEstudiante
                    );

                    cmd.Parameters.AddWithValue(
                        "@NombreCarrera",
                        string.IsNullOrWhiteSpace(nombreCarrera)
                            ? DBNull.Value
                            : nombreCarrera
                    );

                    cmd.Parameters.AddWithValue(
                        "@SemestreActual",
                        semestreActual.HasValue
                            ? semestreActual.Value
                            : DBNull.Value
                    );

                    cmd.Parameters.AddWithValue(
                        "@Activo",
                        activo.HasValue
                            ? activo.Value
                            : DBNull.Value
                    );


                    // ==========================================
                    // EJECUTAR PROCEDIMIENTO
                    // ==========================================

                    using (SqlDataReader reader =
                           await cmd.ExecuteReaderAsync())
                    {
                        // ==========================================
                        // PRIMER RESULTADO
                        // LISTA DE ESTUDIANTES
                        // ==========================================

                        while (await reader.ReadAsync())
                        {
                            resultado.Estudiantes.Add(
                                new EstudianteViewModel
                                {
                                    id = reader.GetInt32(
                                        reader.GetOrdinal("id")
                                    ),

                                    nombreCompleto = reader.GetString(
                                        reader.GetOrdinal("nombreCompleto")
                                    ),

                                    email = reader.GetString(
                                        reader.GetOrdinal("email")
                                    ),

                                    codigoEstudiante = reader.IsDBNull(
                                        reader.GetOrdinal("codigoEstudiante"))
                                        ? null
                                        : reader.GetString(
                                            reader.GetOrdinal("codigoEstudiante")
                                        ),

                                    nombreCarrera = reader.IsDBNull(
                                        reader.GetOrdinal("nombreCarrera"))
                                        ? null
                                        : reader.GetString(
                                            reader.GetOrdinal("nombreCarrera")
                                        ),

                                    semestreActual = reader.IsDBNull(reader.GetOrdinal("semestreActual"))
                                        ? 0
                                        : Convert.ToInt32(reader["semestreActual"]
                                        ),

                                    activo = reader.GetBoolean(
                                        reader.GetOrdinal("activo")
                                    ),

                                    fechaRegistro = reader.GetDateTime(
                                        reader.GetOrdinal("fechaRegistro")
                                    )
                                }
                            );
                        }


                        // ==========================================
                        // SEGUNDO RESULTADO
                        // TOTAL DE REGISTROS
                        // ==========================================

                        if (await reader.NextResultAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                resultado.Paginacion.TotalRegistros =
                                    reader.GetInt32(
                                        reader.GetOrdinal("totalRegistros")
                                    );
                            }
                        }
                    }
                }
            }


            // ==========================================
            // GUARDAR FILTROS
            // ==========================================

            resultado.Nombre = nombre;
            resultado.Email = email;
            resultado.CodigoEstudiante = codigoEstudiante;
            resultado.NombreCarrera = nombreCarrera;
            resultado.SemestreActual = semestreActual;
            resultado.Activo = activo;


            return resultado;
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
