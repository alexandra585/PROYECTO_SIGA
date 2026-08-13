
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class SecretariaRepository : AppBaseRepository, ISecretariaRepository
    {
        public SecretariaRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<SecretariaDashboardViewModel> SecretariaDashboard()
        {
            var model = new SecretariaDashboardViewModel();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_SecretariaDashboard", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.TotalAsignacionesCursoDocente = reader.GetInt32(reader.GetOrdinal("totalAsignacionesCursoDocente"));
                            model.TotalMatriculas = reader.GetInt32(reader.GetOrdinal("totalMatriculas"));
                            model.TotalAsignacionesApoderadoEstudiante = reader.GetInt32(reader.GetOrdinal("totalAsignacionesApoderadoEstudiante"));
                            model.PeriodoActivo = reader.GetString(reader.GetOrdinal("periodoActivo"));
                        }
                    }
                }
            }
            return model;
        }

        public async Task<bool> AsignarCursoDocente(int docenteId, int cursoId, int periodoId)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_AsignarCursoDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@docenteId", docenteId);
                    cmd.Parameters.AddWithValue("@cursoId", cursoId);
                    cmd.Parameters.AddWithValue("@periodoId", periodoId);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> AsignarCursoEstudiante(int alumnoId, int cursoDocenteId)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_AsignarCursoEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@alumnoId", alumnoId);
                    cmd.Parameters.AddWithValue("@cursoDocenteId", cursoDocenteId);

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<AsignacionCursoDocenteViewModel> AsignacionCursoDocenteViewModel()
        {
            var model = new AsignacionCursoDocenteViewModel
            {
                Docentes = new List<DocenteViewModel>(),
                Cursos = new List<CursoViewModel>(),
                Periodos = new List<PeriodoAcademico>(),
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_AsignacionCursoDocenteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            model.Docentes.Add(new DocenteViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombreCompleto = reader["nombreCompleto"].ToString(),
                                email = reader["email"].ToString(),
                                especialidad = reader["especialidad"]?.ToString(),
                                gradoAcademico = reader["gradoAcademico"]?.ToString(),
                                activo = Convert.ToBoolean(reader["activo"])
                            });
                        }

                        await reader.NextResultAsync();
                        while (await reader.ReadAsync())
                        {
                            model.Cursos.Add(new CursoViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),
                                codigoCurso = reader["codigoCurso"].ToString(),
                                nombreCurso = reader["nombreCurso"].ToString(),
                                creditos = Convert.ToInt32(reader["creditos"]),
                                horasTeoricas = reader["horasTeoricas"] != DBNull.Value ? Convert.ToInt32(reader["horasTeoricas"]) : 0,
                                horasPracticas = reader["horasPracticas"] != DBNull.Value ? Convert.ToInt32(reader["horasPracticas"]) : 0
                            });
                        }

                        await reader.NextResultAsync();
                        while (await reader.ReadAsync())
                        {
                            model.Periodos.Add(new PeriodoAcademico
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombrePeriodo = reader["nombrePeriodo"].ToString(),
                                esActivo = Convert.ToBoolean(reader["esActivo"])
                            });
                        }
                    }
                }
            }
            return model;
        }

        public async Task<AsignacionCursoEstudianteViewModel> AsignacionCursoEstudianteViewModel()
        {
            var model = new AsignacionCursoEstudianteViewModel
            {
                Estudiantes = new List<EstudianteViewModel>(),
                CursoDocente = new List<CursoDocenteEstudiante>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_AsignacionCursoEstudianteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            model.Estudiantes.Add(new EstudianteViewModel
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombreCompleto = reader["nombreCompleto"].ToString(),
                                email = reader["email"].ToString(),
                                codigoEstudiante = reader["codigoEstudiante"].ToString(),
                                nombreCarrera = reader["nombreCarrera"].ToString(),
                                semestreActual = Convert.ToInt32(reader["semestreActual"]),
                                activo = Convert.ToBoolean(reader["activo"])
                            });
                        }

                        await reader.NextResultAsync();
                        while (await reader.ReadAsync())
                        {
                            model.CursoDocente.Add(new CursoDocenteEstudiante
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombreCurso = reader["nombreCurso"].ToString(),
                                codigoCurso = reader["codigoCurso"].ToString(),
                                nombreDocente = reader["NombreDocente"].ToString(),
                                nombrePeriodo = reader["nombrePeriodo"].ToString()
                            });
                        }
                    }
                }
            }
            return model;
        }

        public async Task<List<AsignacionCursoDocenteVM>> ListAsignacionCursoDocenteViewModel()
        {
            var lista = new List<AsignacionCursoDocenteVM>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ListAsignacionCursoDocenteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            lista.Add(new AsignacionCursoDocenteVM
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("id")),
                                CodigoCurso = reader.GetString(reader.GetOrdinal("codigoCurso")),
                                NombreCurso = reader.GetString(reader.GetOrdinal("nombreCurso")),
                                NombreDocente = reader.GetString(reader.GetOrdinal("nombreDocente")),
                                NombrePeriodo = reader.GetString(reader.GetOrdinal("nombrePeriodo")),
                                CantidadMatriculados = reader.GetInt32(reader.GetOrdinal("cantidadMatriculados"))
                            });
                        }
                    }
                }
            }

            return lista;
        }

        public async Task<int> DesasignarCursoDocenteViewModel(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DesasignarCursoDocenteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<List<AsignacionCursoEstudianteVM>> ListAsignacionCursoEstudianteViewModel()
        {
            var lista = new List<AsignacionCursoEstudianteVM>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ListAsignacionCursoEstudianteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            lista.Add(new AsignacionCursoEstudianteVM
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("id")),
                                CodigoEstudiante = reader.GetString(reader.GetOrdinal("codigoEstudiante")),
                                NombreEstudiante = reader.GetString(reader.GetOrdinal("nombreEstudiante")),
                                CodigoCurso = reader.GetString(reader.GetOrdinal("codigoCurso")),
                                NombreCurso = reader.GetString(reader.GetOrdinal("nombreCurso")),
                                NombreDocente = reader.GetString(reader.GetOrdinal("nombreDocente")),
                                NombrePeriodo = reader.GetString(reader.GetOrdinal("nombrePeriodo")),
                                Estado = reader.GetString(reader.GetOrdinal("estado")),
                                FechaMatricula = reader.GetDateTime(reader.GetOrdinal("fechaMatricula")),
                                CantidadNotas = reader.GetInt32(reader.GetOrdinal("cantidadNotas")),
                                CantidadAsistencias = reader.GetInt32(reader.GetOrdinal("cantidadAsistencias"))
                            });
                        }
                    }
                }
            }

            return lista;
        }

        public async Task<int> DesasignarCursoEstudianteViewModel(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DesasignarCursoEstudianteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<int> AsignarApoderadoEstudiante(int apoderadoId, int estudianteId, string parentesco, string? parentescoDetalle)
        {
            using (var conn = GetConnection())
            {
                await conn.OpenAsync();
                using (var cmd = new SqlCommand("usp_AsignarApoderadoEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@apoderadoId", apoderadoId);
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);
                    cmd.Parameters.AddWithValue("@parentesco", parentesco);
                    cmd.Parameters.AddWithValue("@parentescoDetalle", (object?)parentescoDetalle ?? DBNull.Value);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        public async Task<AsignacionApoderadoEstudianteViewModel> AsignacionApoderadoEstudianteViewModel()
        {
            var model = new AsignacionApoderadoEstudianteViewModel();

            using (var conn = GetConnection())
            {
                await conn.OpenAsync();

                using (var cmd = new SqlCommand("usp_ListApoderadosActivos", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            model.Apoderados.Add(new UsuarioSimpleVM
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("id")),
                                NombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                Email = reader.GetString(reader.GetOrdinal("email"))
                            });
                        }
                    }
                }

                using (var cmd = new SqlCommand("usp_Estudiantes", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            model.Estudiantes.Add(new EstudianteSimpleVM
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("id")),
                                NombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto")),
                                CodigoEstudiante = reader.GetString(reader.GetOrdinal("codigoEstudiante")),
                                NombreCarrera = reader.GetString(reader.GetOrdinal("nombreCarrera")),
                                SemestreActual = reader.GetByte(reader.GetOrdinal("semestreActual"))
                            });
                        }
                    }
                }
            }

            return model;
        }

        public async Task<List<ApoderadoAsignacionGrupoVM>> ListAsignacionApoderadoEstudianteViewModel()
        {
            var grupos = new Dictionary<int, ApoderadoAsignacionGrupoVM>();

            using (var conn = GetConnection())
            {
                await conn.OpenAsync();
                using (var cmd = new SqlCommand("usp_ListAsignacionApoderadoEstudianteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            int apoderadoId = reader.GetInt32(reader.GetOrdinal("apoderadoId"));

                            if (!grupos.TryGetValue(apoderadoId, out var grupo))
                            {
                                grupo = new ApoderadoAsignacionGrupoVM
                                {
                                    ApoderadoId = apoderadoId,
                                    NombreApoderado = reader.GetString(reader.GetOrdinal("NombreApoderado")),
                                    EmailApoderado = reader.GetString(reader.GetOrdinal("EmailApoderado")),
                                    Hijos = new List<ApoderadoEstudianteDetalleVM>()
                                };
                                grupos[apoderadoId] = grupo;
                            }

                            grupo.Hijos.Add(new ApoderadoEstudianteDetalleVM
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("id")),
                                EstudianteId = reader.GetInt32(reader.GetOrdinal("estudianteId")),
                                NombreEstudiante = reader.GetString(reader.GetOrdinal("NombreEstudiante")),
                                CodigoEstudiante = reader.GetString(reader.GetOrdinal("codigoEstudiante")),
                                Parentesco = reader.GetString(reader.GetOrdinal("parentesco")),
                                ParentescoDetalle = reader.IsDBNull(reader.GetOrdinal("parentescoDetalle")) ? null : reader.GetString(reader.GetOrdinal("parentescoDetalle")),
                                FechaRegistro = reader.GetDateTime(reader.GetOrdinal("fechaRegistro"))
                            });
                        }
                    }
                }
            }

            foreach (var g in grupos.Values)
                g.CantidadHijos = g.Hijos.Count;

            return grupos.Values
                .OrderBy(g => g.NombreApoderado)
                .ToList();
        }

        public async Task<int> DesasignarApoderadoEstudianteViewModel(int id)
        {
            using (var conn = GetConnection())
            {
                await conn.OpenAsync();
                using (var cmd = new SqlCommand("usp_DesasignarApoderadoEstudianteVM", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id", id);

                    var result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }
    }
}
