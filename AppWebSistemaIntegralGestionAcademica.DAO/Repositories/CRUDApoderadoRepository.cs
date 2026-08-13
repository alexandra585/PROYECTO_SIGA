using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class CRUDApoderadoRepository : AppBaseRepository, ICRUDApoderadoRepository
    {
        public CRUDApoderadoRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<ApoderadoListadoViewModel> ListApoderadoPaginado(
            int pagina,
            int tamanioPagina,
            string? nombre = null,
            string? email = null,
            string? dni = null,
            string? telefono = null,
            string? direccion = null,
            int? cantidadHijos = null,
            bool? activo = null)
        {
            var resultado = new ApoderadoListadoViewModel();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ApoderadosPaginado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanioPagina", tamanioPagina);

                    cmd.Parameters.AddWithValue(
                        "@Nombre",
                        string.IsNullOrWhiteSpace(nombre) ? DBNull.Value : nombre
                    );

                    cmd.Parameters.AddWithValue(
                        "@Email",
                        string.IsNullOrWhiteSpace(email) ? DBNull.Value : email
                    );

                    cmd.Parameters.AddWithValue(
                        "@Dni",
                        string.IsNullOrWhiteSpace(dni) ? DBNull.Value : dni
                    );

                    cmd.Parameters.AddWithValue(
                        "@Telefono",
                        string.IsNullOrWhiteSpace(telefono) ? DBNull.Value : telefono
                    );

                    cmd.Parameters.AddWithValue(
                        "@Direccion",
                        string.IsNullOrWhiteSpace(direccion) ? DBNull.Value : direccion
                    );

                    cmd.Parameters.AddWithValue(
                        "@CantidadHijos",
                        cantidadHijos.HasValue ? cantidadHijos.Value : DBNull.Value
                    );

                    cmd.Parameters.AddWithValue(
                        "@Activo",
                        activo.HasValue ? activo.Value : DBNull.Value
                    );

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        // ==========================================
                        // PRIMER RESULTADO: APODERADOS
                        // ==========================================

                        while (await reader.ReadAsync())
                        {
                            resultado.Apoderados.Add(new ApoderadoViewModel
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),

                                nombreCompleto = reader.GetString(
                                    reader.GetOrdinal("nombreCompleto")
                                ),

                                email = reader.GetString(
                                    reader.GetOrdinal("email")
                                ),

                                activo = reader.GetBoolean(
                                    reader.GetOrdinal("activo")
                                ),

                                fechaRegistro = reader.GetDateTime(
                                    reader.GetOrdinal("fechaRegistro")
                                ),

                                telefono = reader.IsDBNull(
                                    reader.GetOrdinal("telefono")
                                )
                                    ? null
                                    : reader.GetString(
                                        reader.GetOrdinal("telefono")
                                    ),

                                dni = reader.IsDBNull(
                                    reader.GetOrdinal("dni")
                                )
                                    ? null
                                    : reader.GetString(
                                        reader.GetOrdinal("dni")
                                    ),

                                direccion = reader.IsDBNull(
                                    reader.GetOrdinal("direccion")
                                )
                                    ? null
                                    : reader.GetString(
                                        reader.GetOrdinal("direccion")
                                    ),

                                cantidadHijos = reader.GetInt32(
                                    reader.GetOrdinal("cantidadHijos")
                                )
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
                                    reader.GetInt32(
                                        reader.GetOrdinal("totalRegistros")
                                    );
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

            resultado.Nombre = nombre;
            resultado.Email = email;
            resultado.Dni = dni;
            resultado.Telefono = telefono;
            resultado.Direccion = direccion;
            resultado.CantidadHijos = cantidadHijos;
            resultado.Activo = activo;

            return resultado;
        }

        public async Task<ApoderadoViewModel> ApoderadoId(int id)
        {
            ApoderadoViewModel apoderado = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ApoderadoId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            apoderado = new ApoderadoViewModel
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                email = reader.GetString(reader.GetOrdinal("email")),
                                activo = reader.GetBoolean(reader.GetOrdinal("activo")),
                                fechaRegistro = reader.GetDateTime(reader.GetOrdinal("fechaRegistro")),
                                telefono = reader.IsDBNull(reader.GetOrdinal("telefono")) ? null : reader.GetString(reader.GetOrdinal("telefono")),
                                dni = reader.GetString(reader.GetOrdinal("dni")),
                                direccion = reader.IsDBNull(reader.GetOrdinal("direccion")) ? null : reader.GetString(reader.GetOrdinal("direccion"))
                            };
                        }
                    }
                }
            }
            return apoderado;
        }

        public async Task<int> CreateUsuarioApoderado(ApoderadoViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateUsuarioApoderado", conn))
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

        public async Task<bool> CreateApoderado(int id, ApoderadoViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateApoderado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@telefono", model.telefono);
                    cmd.Parameters.AddWithValue("@dni", model.dni);
                    cmd.Parameters.AddWithValue("@direccion", model.direccion);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> UpdateApoderado(ApoderadoViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UpdateApoderado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", model.id);
                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@activo", model.activo);
                    cmd.Parameters.AddWithValue("@telefono", model.telefono);
                    cmd.Parameters.AddWithValue("@dni", model.dni ?? "");
                    cmd.Parameters.AddWithValue("@direccion", model.direccion);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> DeleteApoderado(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DeleteApoderado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ExisteEmailApoderado(string email, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteEmailApoderado", conn))
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

        public async Task<bool> ExisteDniApoderado(string dni, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteDniApoderado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@dni", dni);
                    cmd.Parameters.AddWithValue("@idExcluir", (object?)idExcluir ?? DBNull.Value);

                    var result = await cmd.ExecuteScalarAsync();
                    int count = result != null ? Convert.ToInt32(result) : 0;

                    return count > 0;
                }
            }
        }
    }
}
