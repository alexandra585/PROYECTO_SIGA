using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class CRUDDocenteRepository : AppBaseRepository, ICRUDDocenteRepository
    {
        public CRUDDocenteRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<DocenteListadoViewModel> ListDocente(
            int pagina = 1,
            int tamanioPagina = 10,
            string? nombre = null,
            string? email = null,
            string? especialidad = null,
            string? gradoAcademico = null,
            bool? activo = true)
        {
            var resultado = new DocenteListadoViewModel();

            // ==========================================
            // CONFIGURAR PAGINACIÓN
            // ==========================================

            resultado.Paginacion.Pagina = pagina;
            resultado.Paginacion.TamanioPagina = tamanioPagina;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand(
                    "usp_DocentesPaginado",
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
                        "@Especialidad",
                        string.IsNullOrWhiteSpace(especialidad)
                            ? DBNull.Value
                            : especialidad
                    );

                    cmd.Parameters.AddWithValue(
                        "@GradoAcademico",
                        string.IsNullOrWhiteSpace(gradoAcademico)
                            ? DBNull.Value
                            : gradoAcademico
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
                        // LISTA DE DOCENTES
                        // ==========================================

                        while (await reader.ReadAsync())
                        {
                            resultado.Docentes.Add(
                                new DocenteViewModel
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

                                    especialidad = reader.IsDBNull(
                                        reader.GetOrdinal("especialidad"))
                                        ? null
                                        : reader.GetString(
                                            reader.GetOrdinal("especialidad")
                                        ),

                                    gradoAcademico = reader.IsDBNull(
                                        reader.GetOrdinal("gradoAcademico"))
                                        ? null
                                        : reader.GetString(
                                            reader.GetOrdinal("gradoAcademico")
                                        ),

                                    activo = reader.GetBoolean(
                                        reader.GetOrdinal("activo")
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
            resultado.Especialidad = especialidad;
            resultado.GradoAcademico = gradoAcademico;
            resultado.Activo = activo;

            return resultado;
        }

        public async Task<DocenteViewModel> DocenteId(int id)
        {
            DocenteViewModel docente = null;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DocenteId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            docente = new DocenteViewModel
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                email = reader.GetString(reader.GetOrdinal("email")),
                                especialidad = reader.IsDBNull(reader.GetOrdinal("especialidad")) ? null : reader.GetString(reader.GetOrdinal("especialidad")),
                                gradoAcademico = reader.IsDBNull(reader.GetOrdinal("gradoAcademico")) ? null : reader.GetString(reader.GetOrdinal("gradoAcademico")),
                                activo = reader.GetBoolean(reader.GetOrdinal("activo"))
                            };
                        }
                    }
                }
            }
            return docente;
        }

        public async Task<int> CreateUsuarioDocente(DocenteViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateUsuarioDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    string contraseniaEncriptada = ContraseniaHelper.EncriptarContrasenia("123456");

                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@contrasenia", contraseniaEncriptada);
                    cmd.Parameters.AddWithValue("@activo", model.activo);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<bool> CreateDocente(int usuarioId, DocenteViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CreateDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", usuarioId);
                    cmd.Parameters.AddWithValue("@especialidad", model.especialidad ?? "");
                    cmd.Parameters.AddWithValue("@gradoAcademico", model.gradoAcademico ?? "");

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> UpdateDocente(DocenteViewModel model)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_UpdateDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@id", model.id);
                    cmd.Parameters.AddWithValue("@nombreCompleto", model.nombreCompleto);
                    cmd.Parameters.AddWithValue("@email", model.email);
                    cmd.Parameters.AddWithValue("@activo", model.activo);
                    cmd.Parameters.AddWithValue("@especialidad", model.especialidad ?? "");
                    cmd.Parameters.AddWithValue("@gradoAcademico", model.gradoAcademico ?? "");

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> DeleteDocente(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DeleteDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> ExisteEmailDocente(string email, int? idExcluir = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ExisteEmailDocente", conn))
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

        public async Task<List<UsuarioViewModel>> BuscarUsuarioDisponibleDocente(string? filtro)
        {
            var usuarios = new List<UsuarioViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_BuscarUsuarioDisponibleDocente", conn))
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

        public async Task<bool> ActualizarRolUsuarioDocente(int id, string rol)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ActualizarRolUsuarioDocente", conn))
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
