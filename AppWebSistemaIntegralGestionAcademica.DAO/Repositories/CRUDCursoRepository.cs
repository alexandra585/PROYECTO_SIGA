using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class CRUDCursoRepository : AppBaseRepository, ICRUDCursoRepository
    {
        public CRUDCursoRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<CursoListadoViewModel> ListCurso(
            int pagina = 1,
            int tamanioPagina = 10,
            string? codigoCurso = null,
            string? nombreCurso = null,
            int? creditos = null)
        {
            var resultado = new CursoListadoViewModel();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CursosPaginado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ==========================================
                    // PARÁMETROS DE PAGINACIÓN
                    // ==========================================
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanioPagina", tamanioPagina);

                    // ==========================================
                    // PARÁMETROS DE FILTROS
                    // ==========================================
                    cmd.Parameters.AddWithValue(
                        "@CodigoCurso",
                        (object?)codigoCurso ?? DBNull.Value
                    );

                    cmd.Parameters.AddWithValue(
                        "@NombreCurso",
                        (object?)nombreCurso ?? DBNull.Value
                    );

                    cmd.Parameters.AddWithValue(
                        "@Creditos",
                        (object?)creditos ?? DBNull.Value
                    );

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        // ==========================================
                        // PRIMER RESULTADO: CURSOS
                        // ==========================================
                        while (await reader.ReadAsync())
                        {
                            resultado.Cursos.Add(new CursoViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),

                                codigoCurso = reader["codigoCurso"]?.ToString(),

                                nombreCurso = reader["nombreCurso"]?.ToString(),

                                creditos = Convert.ToInt32(reader["creditos"]),

                                horasTeoricas = reader["horasTeoricas"] != DBNull.Value
                                    ? Convert.ToInt32(reader["horasTeoricas"])
                                    : 0,

                                horasPracticas = reader["horasPracticas"] != DBNull.Value
                                    ? Convert.ToInt32(reader["horasPracticas"])
                                    : 0
                            });
                        }


                        // ==========================================
                        // SEGUNDO RESULTADO: TOTAL REGISTROS
                        // ==========================================
                        if (await reader.NextResultAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                resultado.Paginacion.TotalRegistros =
                                    Convert.ToInt32(reader["totalRegistros"]);
                            }
                        }
                    }
                }
            }

            // ==========================================
            // CONFIGURAR PAGINACIÓN
            // ==========================================
            resultado.Paginacion.Pagina = pagina;

            resultado.Paginacion.TamanioPagina = tamanioPagina;


            // ==========================================
            // CONSERVAR FILTROS
            // ==========================================
            resultado.CodigoCurso = codigoCurso;

            resultado.NombreCurso = nombreCurso;

            resultado.Creditos = creditos;


            return resultado;

        }


        public async Task<CursoViewModel> CursoId(int id)
        {
            CursoViewModel curso = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CursoId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            curso = new CursoViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),
                                codigoCurso = reader["codigoCurso"].ToString(),
                                nombreCurso = reader["nombreCurso"].ToString(),
                                creditos = Convert.ToInt32(reader["creditos"]),
                                horasTeoricas = reader["horasTeoricas"] != DBNull.Value ? Convert.ToInt32(reader["horasTeoricas"]) : 0,
                                horasPracticas = reader["horasPracticas"] != DBNull.Value ? Convert.ToInt32(reader["horasPracticas"]) : 0
                            };
                        }
                    }
                }
            }
            return curso;
        }

        public async Task<bool> CreateCurso(CursoViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateCurso", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@codigoCurso", model.codigoCurso);
                    cmd.Parameters.AddWithValue("@nombreCurso", model.nombreCurso);
                    cmd.Parameters.AddWithValue("@creditos", model.creditos);
                    cmd.Parameters.AddWithValue("@horasTeoricas", model.horasTeoricas);
                    cmd.Parameters.AddWithValue("@horasPracticas", model.horasPracticas);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> UpdateCurso(CursoViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UpdateCurso", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", model.id);
                    cmd.Parameters.AddWithValue("@codigoCurso", model.codigoCurso);
                    cmd.Parameters.AddWithValue("@nombreCurso", model.nombreCurso);
                    cmd.Parameters.AddWithValue("@creditos", model.creditos);
                    cmd.Parameters.AddWithValue("@horasTeoricas", model.horasTeoricas);
                    cmd.Parameters.AddWithValue("@horasPracticas", model.horasPracticas);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> DeleteCurso(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DeleteCurso", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ExisteCodigoCurso(string codigoCurso, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteCodigoCurso", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@codigoCurso", codigoCurso);
                    cmd.Parameters.AddWithValue("@idExcluir", (object?)idExcluir ?? DBNull.Value);

                    int count = (int)await cmd.ExecuteScalarAsync();
                    return count > 0;
                }
            }
        }
    }
}
