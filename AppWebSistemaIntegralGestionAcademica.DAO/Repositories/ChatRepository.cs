using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class ChatRepository : AppBaseRepository, IChatRepository
    {
        public ChatRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<MensajesApoderadoViewModel> ListarChatDocenteApoderado(int apoderadoId)
        {
            var model = new MensajesApoderadoViewModel
            {
                ApoderadoId = apoderadoId,
                Docentes = new List<ChatDocenteViewModel>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ListarChatDocenteApoderado", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@apoderadoId", apoderadoId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.NombreApoderado = reader["nombreCompleto"]?.ToString() ?? "";
                        }

                        await reader.NextResultAsync();

                        while (await reader.ReadAsync())
                        {
                            model.Docentes.Add(new ChatDocenteViewModel
                            {
                                DocenteId = Convert.ToInt32(reader["docenteId"]),
                                NombreCompleto = reader["nombreCompleto"]?.ToString() ?? "",
                                Especialidad = reader["especialidad"] as string,
                                CursosRelacionados = reader["cursosRelacionados"] as string,
                                ConversacionId = reader["conversacionId"] == DBNull.Value ? null : Convert.ToInt32(reader["conversacionId"]),
                                UltimoMensaje = reader["ultimoMensaje"] as string,
                                UltimoMensajeFecha = reader["ultimoMensajeFecha"] == DBNull.Value ? null : Convert.ToDateTime(reader["ultimoMensajeFecha"]),
                                MensajesNoLeidos = Convert.ToInt32(reader["mensajesNoLeidos"]),
                                EnLinea = false
                            });
                        }
                    }
                }
            }

            return model;
        }

        public async Task<MensajesDocenteViewModel> ListarChatApoderadoDocente(int docenteId)
        {
            var model = new MensajesDocenteViewModel
            {
                DocenteId = docenteId,
                Apoderados = new List<ChatApoderadoViewModel>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();
                using (SqlCommand cmd = new SqlCommand("usp_ListarChatApoderadoDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@docenteId", docenteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                            model.NombreDocente = reader["nombreCompleto"]?.ToString() ?? "";

                        await reader.NextResultAsync();

                        while (await reader.ReadAsync())
                        {
                            model.Apoderados.Add(new ChatApoderadoViewModel
                            {
                                ApoderadoId = Convert.ToInt32(reader["apoderadoId"]),
                                NombreCompleto = reader["nombreCompleto"]?.ToString() ?? "",
                                HijosRelacionados = reader["hijosRelacionados"] as string,
                                ConversacionId = reader["conversacionId"] == DBNull.Value ? null : Convert.ToInt32(reader["conversacionId"]),
                                UltimoMensaje = reader["ultimoMensaje"] as string,
                                UltimoMensajeFecha = reader["ultimoMensajeFecha"] == DBNull.Value ? null : Convert.ToDateTime(reader["ultimoMensajeFecha"]),
                                MensajesNoLeidos = Convert.ToInt32(reader["mensajesNoLeidos"]),
                                EnLinea = false
                            });
                        }
                    }
                }
            }

            return model;
        }

        public async Task<int> ObtenerCrearChatConversacion(int apoderadoId, int docenteId, int? cursoId = null)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ObtenerCrearChatConversacion", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@apoderadoId", apoderadoId);
                    cmd.Parameters.AddWithValue("@docenteId", docenteId);
                    cmd.Parameters.AddWithValue("@cursoId", (object?)cursoId ?? DBNull.Value);

                    var result = await cmd.ExecuteScalarAsync();

                    if (result == null || result == DBNull.Value)
                        throw new Exception("No se pudo obtener o crear la conversación.");

                    return Convert.ToInt32(result);
                }
            }
        }

        public async Task<ChatConversacionViewModel> ObtenerChatConversacion(int conversacionId, int usuarioActualId)
        {
            var model = new ChatConversacionViewModel
            {
                ConversacionId = conversacionId,
                Mensajes = new List<ChatMensajeViewModel>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ObtenerChatConversacion", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@conversacionId", conversacionId);
                    cmd.Parameters.AddWithValue("@usuarioActualId", usuarioActualId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.ApoderadoId = Convert.ToInt32(reader["apoderadoId"]);
                            model.DocenteId = Convert.ToInt32(reader["docenteId"]);
                            model.NombreApoderado = reader["nombreApoderado"]?.ToString() ?? "";
                            model.NombreDocente = reader["nombreDocente"]?.ToString() ?? "";
                            model.EspecialidadDocente = reader["especialidad"] as string;
                        }

                        if (await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var remitenteId = Convert.ToInt32(reader["remitenteId"]);

                                model.Mensajes.Add(new ChatMensajeViewModel
                                {
                                    Id = Convert.ToInt64(reader["id"]),
                                    ConversacionId = conversacionId,
                                    RemitenteId = remitenteId,
                                    NombreRemitente = reader["nombreRemitente"]?.ToString() ?? "",
                                    Contenido = reader["contenido"]?.ToString() ?? "",
                                    FechaEnvio = Convert.ToDateTime(reader["fechaEnvio"]),
                                    Leido = Convert.ToBoolean(reader["leido"]),
                                    EsMio = remitenteId == usuarioActualId
                                });
                            }
                        }
                    }
                }
            }

            return model;
        }

        public async Task<ChatMensajeViewModel> EnviarChatMensaje(int conversacionId, int remitenteId, string contenido)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_EnviarChatMensaje", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@conversacionId", conversacionId);
                    cmd.Parameters.AddWithValue("@remitenteId", remitenteId);
                    cmd.Parameters.AddWithValue("@contenido", contenido);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            return new ChatMensajeViewModel
                            {
                                Id = Convert.ToInt64(reader["id"]),
                                ConversacionId = conversacionId,
                                RemitenteId = remitenteId,
                                NombreRemitente = reader["nombreRemitente"]?.ToString() ?? "",
                                Contenido = contenido,
                                FechaEnvio = Convert.ToDateTime(reader["fechaEnvio"]),
                                Leido = false,
                                EsMio = true
                            };
                        }
                    }
                }
            }

            throw new Exception("No se pudo enviar el mensaje.");
        }

        public async Task MarcarChatComoLeido(int conversacionId, int usuarioId)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_MarcarChatComoLeido", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@conversacionId", conversacionId);
                    cmd.Parameters.AddWithValue("@usuarioId", usuarioId);

                    await cmd.ExecuteNonQueryAsync();
                }
            }
        }

        public async Task EliminarChat(int conversacionId, int usuarioId)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_EliminarChat", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@conversacionId", conversacionId);
                    cmd.Parameters.AddWithValue("@usuarioId", usuarioId);

                    await cmd.ExecuteNonQueryAsync();
                }
            }
        }

        public async Task VaciarChat(int conversacionId, int usuarioId)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_VaciarChat", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@conversacionId", conversacionId);
                    cmd.Parameters.AddWithValue("@usuarioId", usuarioId);

                    await cmd.ExecuteNonQueryAsync();
                }
            }
        }
    }
}