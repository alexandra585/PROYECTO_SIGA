using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class CRUDSecretariaRepository : AppBaseRepository, ICRUDSecretariaRepository
    {
        public CRUDSecretariaRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<SecretariaListadoViewModel> ListSecretaria(
            int pagina = 1,
            int tamanioPagina = 10,
            string? nombre = null,
            string? email = null,
            string? cargo = null,
            string? telefono = null,
            bool? activo = true)
        {
            var resultado = new SecretariaListadoViewModel();

            resultado.Paginacion.Pagina = pagina;
            resultado.Paginacion.TamanioPagina = tamanioPagina;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand(
                    "usp_SecretariasPaginado",
                    conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ==========================================
                    // PARÁMETROS
                    // ==========================================

                    cmd.Parameters.AddWithValue(
                        "@Pagina",
                        pagina
                    );

                    cmd.Parameters.AddWithValue(
                        "@TamanioPagina",
                        tamanioPagina
                    );

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
                        "@Cargo",
                        string.IsNullOrWhiteSpace(cargo)
                            ? DBNull.Value
                            : cargo
                    );

                    cmd.Parameters.AddWithValue(
                        "@Telefono",
                        string.IsNullOrWhiteSpace(telefono)
                            ? DBNull.Value
                            : telefono
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
                        // LISTA DE SECRETARIAS
                        // ==========================================

                        while (await reader.ReadAsync())
                        {
                            resultado.Secretarias.Add(
                                new SecretariaViewModel
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

                                    cargo = reader.IsDBNull(
                                        reader.GetOrdinal("cargo"))
                                        ? null
                                        : reader.GetString(
                                            reader.GetOrdinal("cargo")
                                        ),

                                    telefono = reader.IsDBNull(
                                        reader.GetOrdinal("telefono"))
                                        ? null
                                        : reader.GetString(
                                            reader.GetOrdinal("telefono")
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
            resultado.Cargo = cargo;
            resultado.Telefono = telefono;
            resultado.Activo = activo;

            return resultado;
        }

        public async Task<SecretariaViewModel> SecretariaId(int id)
        {
            SecretariaViewModel secretaria = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_SecretariaId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            secretaria = new SecretariaViewModel
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                email = reader.GetString(reader.GetOrdinal("email")),
                                cargo = reader.IsDBNull(reader.GetOrdinal("cargo")) ? null : reader.GetString(reader.GetOrdinal("cargo")),
                                telefono = reader.IsDBNull(reader.GetOrdinal("telefono")) ? null : reader.GetString(reader.GetOrdinal("telefono")),
                                activo = reader.GetBoolean(reader.GetOrdinal("activo")),
                                fechaRegistro = reader.GetDateTime(reader.GetOrdinal("fechaRegistro"))
                            };
                        }
                    }
                }
            }
            return secretaria;
        }

        public async Task<int> CreateUsuarioSecretaria(SecretariaViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateUsuarioSecretaria", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    string contraseniaEncriptada = ContraseniaHelper.EncriptarContrasenia("123456");

                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@contrasenia", ContraseniaHelper.EncriptarContrasenia("123456"));
                    cmd.Parameters.AddWithValue("@activo", model.activo);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<bool> CreateSecretaria(int id, SecretariaViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateSecretaria", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@cargo", model.cargo);
                    cmd.Parameters.AddWithValue("@telefono", model.telefono);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> UpdateSecretaria(SecretariaViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UpdateSecretaria", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", model.id);
                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@activo", model.activo);
                    cmd.Parameters.AddWithValue("@cargo", model.cargo);
                    cmd.Parameters.AddWithValue("@telefono", model.telefono);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> DeleteSecretaria(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DeleteSecretaria", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ExisteEmailSecretaria(string email, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteEmailSecretaria", conn))
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

        public async Task<List<UsuarioViewModel>> BuscarUsuarioDisponibleSecretaria(string? filtro)
        {
            var usuarios = new List<UsuarioViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_BuscarUsuarioDisponibleSecretaria", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@filtro", (object?)filtro ?? DBNull.Value);

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
                                activo = reader.GetBoolean(reader.GetOrdinal("activo"))
                            });
                        }
                    }
                }
            }

            return usuarios;
        }

        public async Task<bool> ActualizarRolUsuarioSecretaria(int id, string rol)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ActualizarRolUsuarioSecretaria", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@rol", rol);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }
    }
}
