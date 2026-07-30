using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class DocenteRepository : AppBaseRepository, IDocenteRepository
    {
        public DocenteRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<DocenteDashboardViewModel> DocenteDashboard(int usuarioId)
        {
            var model = new DocenteDashboardViewModel
            {
                CursosAsignados = new List<CursoDocente>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DocenteDashboard", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usuarioId", usuarioId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.nombreCompleto = reader.GetString(reader.GetOrdinal("nombreCompleto"));
                            model.especialidad = reader.IsDBNull(reader.GetOrdinal("especialidad")) ? "No especificada" : reader.GetString(reader.GetOrdinal("especialidad"));
                            model.gradoAcademico = reader.IsDBNull(reader.GetOrdinal("gradoAcademico")) ? "No especificado" : reader.GetString(reader.GetOrdinal("gradoAcademico"));
                        }

                        await reader.NextResultAsync();

                        while (await reader.ReadAsync())
                        {
                            model.CursosAsignados.Add(new CursoDocente
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCurso = reader.GetString(reader.GetOrdinal("nombreCurso")),
                                codigoCurso = reader.GetString(reader.GetOrdinal("codigoCurso")),
                                nombrePeriodo = reader.GetString(reader.GetOrdinal("nombrePeriodo"))
                            });
                        }
                    }
                }
            }

            model.totalCursosAsignados = model.CursosAsignados.Count;
            return model;
        }

        public async Task<List<CursoDocenteViewModel>> CursosAsignadosDocente(int docenteId)
        {
            var cursos = new List<CursoDocenteViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CursosAsignadosDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@docenteId", docenteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            cursos.Add(new CursoDocenteViewModel
                            {
                                CursoDocenteId = Convert.ToInt32(reader["CursoDocenteId"]),
                                CursoId = Convert.ToInt32(reader["CursoId"]),
                                CodigoCurso = Convert.ToString(reader["codigoCurso"]) ?? string.Empty,
                                NombreCurso = Convert.ToString(reader["nombreCurso"]) ?? string.Empty,
                                Creditos = Convert.ToInt32(reader["creditos"]),
                                NombrePeriodo = Convert.ToString(reader["nombrePeriodo"]) ?? string.Empty,
                                PeriodoId = Convert.ToInt32(reader["PeriodoId"])
                            });
                        }
                    }
                }
            }
            return cursos;
        }

        public async Task<List<CursoEstudianteViewModel>> CursosEstudiantesDocente(int cursoDocenteId)
        {
            var estudiantes = new List<CursoEstudianteViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CursosEstudiantesDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@cursoDocenteId", cursoDocenteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            estudiantes.Add(new CursoEstudianteViewModel
                            {
                                MatriculaId = Convert.ToInt32(reader["MatriculaId"]),
                                EstudianteId = Convert.ToInt32(reader["EstudianteId"]),
                                NombreCompleto = Convert.ToString(reader["nombreCompleto"]) ?? string.Empty,
                                CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? string.Empty,
                                NombreCarrera = Convert.ToString(reader["nombreCarrera"]) ?? string.Empty,
                                SemestreActual = Convert.ToInt32(reader["semestreActual"]),
                                EstadoMatricula = Convert.ToString(reader["EstadoMatricula"]) ?? string.Empty,
                                PromedioActual = Convert.ToDouble(reader["PromedioActual"])
                            });
                        }
                    }
                }
            }
            return estudiantes;
        }

        public async Task<List<EvaluacionNotaViewModel>> CursosEvaluacionesDocente(int cursoDocenteId)
        {
            var evaluaciones = new List<EvaluacionNotaViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CursosEvaluacionesDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@cursoDocenteId", cursoDocenteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            evaluaciones.Add(new EvaluacionNotaViewModel
                            {
                                EvaluacionId = Convert.ToInt32(reader["EvaluacionId"]),
                                Nombre = Convert.ToString(reader["NombreEvaluacion"]) ?? string.Empty,
                                TipoEvaluacion = Convert.ToString(reader["TipoEvaluacion"]) ?? string.Empty,
                                FechaEvaluacion = Convert.ToDateTime(reader["fechaEvaluacion"]),
                                NotaPorcentual = Convert.ToDecimal(reader["notaPorcentual"])
                            });
                        }
                    }
                }
            }
            return evaluaciones;
        }

        public async Task<List<NotaViewModel>> ObtenerNotasPorMatricula(int matriculaId)
        {
            var notas = new List<NotaViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ObtenerNotasPorMatricula", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@matriculaId", matriculaId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            notas.Add(new NotaViewModel
                            {
                                NotaId = Convert.ToInt32(reader["NotaId"]),
                                EvaluacionId = Convert.ToInt32(reader["evaluacionId"]),
                                NombreEvaluacion = reader["NombreEvaluacion"].ToString(),
                                Nota = reader["nota"] != DBNull.Value ? Convert.ToDecimal(reader["nota"]) : 0,
                                Observacion = reader["observacion"]?.ToString(),
                                FechaRegistro = reader["fechaRegistro"] != DBNull.Value ? Convert.ToDateTime(reader["fechaRegistro"]) : (DateTime?)null
                            });
                        }
                    }
                }
            }
            return notas;
        }

        public async Task<Dictionary<int, Dictionary<int, (decimal nota, string observacion)>>> ObtenerNotasExistentes(int cursoDocenteId)
        {
            var resultado = new Dictionary<int, Dictionary<int, (decimal nota, string observacion)>>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ObtenerNotasExistentes", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@cursoDocenteId", cursoDocenteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            int matriculaId = Convert.ToInt32(reader["matriculaId"]);
                            int evaluacionId = Convert.ToInt32(reader["evaluacionId"]);
                            decimal nota = Convert.ToDecimal(reader["nota"]);
                            string observacion = reader["observacion"] != DBNull.Value ? Convert.ToString(reader["observacion"]) : string.Empty;

                            if (!resultado.ContainsKey(matriculaId))
                            {
                                resultado[matriculaId] = new Dictionary<int, (decimal, string)>();
                            }
                            resultado[matriculaId][evaluacionId] = (nota, observacion);
                        }
                    }
                }
            }
            return resultado;
        }

        public async Task<bool> RegistrarNotas(int matriculaId, int evaluacionId, decimal nota, int docenteId, string observacion)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_RegistrarNotas", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@matriculaId", matriculaId);
                    cmd.Parameters.AddWithValue("@evaluacionId", evaluacionId);
                    cmd.Parameters.AddWithValue("@nota", nota);
                    cmd.Parameters.AddWithValue("@docenteId", docenteId);
                    cmd.Parameters.AddWithValue("@observacion", observacion ?? "");

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<bool> RegistrarAsistencias(int matriculaId, string estado, int docenteId, string observacion)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_RegistrarAsistencias", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@matriculaId", matriculaId);
                    cmd.Parameters.AddWithValue("@estado", estado);
                    cmd.Parameters.AddWithValue("@docenteId", docenteId);
                    cmd.Parameters.AddWithValue("@observacion", observacion ?? "");

                    var result = await cmd.ExecuteScalarAsync();
                    int filasAfectadas = result != null ? Convert.ToInt32(result) : 0;

                    return filasAfectadas > 0;
                }
            }
        }

        public async Task<List<AsistenciaViewModel>> ObtenerAsistenciasPorCurso(int cursoDocenteId, DateTime? fecha = null)
        {
            var asistencias = new List<AsistenciaViewModel>();
            DateTime fechaFiltro = fecha ?? DateTime.Today;

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ObtenerAsistenciasPorCurso", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@cursoDocenteId", cursoDocenteId);
                    cmd.Parameters.AddWithValue("@fecha", fechaFiltro.Date);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            asistencias.Add(new AsistenciaViewModel
                            {
                                MatriculaId = Convert.ToInt32(reader["MatriculaId"]),
                                EstudianteId = Convert.ToInt32(reader["EstudianteId"]),
                                NombreCompleto = Convert.ToString(reader["nombreCompleto"]) ?? string.Empty,
                                CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? string.Empty,
                                EstadoAsistencia = Convert.ToString(reader["EstadoAsistencia"]) ?? string.Empty,
                                Observacion = reader["observacion"] != DBNull.Value ? Convert.ToString(reader["observacion"]) : null,
                                HoraRegistro = reader["horaRegistro"] != DBNull.Value ? TimeSpan.Parse(reader["horaRegistro"].ToString()) : (TimeSpan?)null
                            });
                        }
                    }
                }
            }
            return asistencias;
        }

        public async Task<ReporteCursoViewModel> ObtenerReporteCurso(int cursoDocenteId)
        {
            var reporte = new ReporteCursoViewModel();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ObtenerReporteCurso", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@cursoDocenteId", cursoDocenteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            reporte.NombreCurso = Convert.ToString(reader["nombreCurso"]) ?? string.Empty;
                            reporte.CodigoCurso = Convert.ToString(reader["codigoCurso"]) ?? string.Empty;
                            reporte.Creditos = Convert.ToInt32(reader["creditos"]);
                            reporte.NombreDocente = Convert.ToString(reader["NombreDocente"]) ?? string.Empty;
                            reporte.NombrePeriodo = Convert.ToString(reader["nombrePeriodo"]) ?? string.Empty;
                        }

                        await reader.NextResultAsync();

                        reporte.Estudiantes = new List<CursoEstudianteViewModel>();

                        while (await reader.ReadAsync())
                        {
                            reporte.Estudiantes.Add(new CursoEstudianteViewModel
                            {
                                MatriculaId = Convert.ToInt32(reader["MatriculaId"]),
                                EstudianteId = Convert.ToInt32(reader["EstudianteId"]),
                                NombreCompleto = Convert.ToString(reader["nombreCompleto"]) ?? string.Empty,
                                CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? string.Empty,
                                NombreCarrera = Convert.ToString(reader["nombreCarrera"]) ?? string.Empty,
                                SemestreActual = Convert.ToInt32(reader["semestreActual"]),
                                EstadoMatricula = Convert.ToString(reader["EstadoMatricula"]) ?? string.Empty,
                                PromedioActual = Convert.ToDouble(reader["PromedioActual"])
                            });
                        }
                    }
                }
            }

            reporte.TotalEstudiantes = reporte.Estudiantes.Count;
            reporte.TotalAprobados = reporte.Estudiantes.Count(e => e.PromedioActual >= 13);
            reporte.TotalDesaprobados = reporte.Estudiantes.Count(e => e.PromedioActual > 0 && e.PromedioActual < 13);
            reporte.TotalSinNotas = reporte.Estudiantes.Count(e => e.PromedioActual == 0);
            reporte.PromedioGeneralCurso = reporte.Estudiantes.Count > 0 ? reporte.Estudiantes.Average(e => e.PromedioActual) : 0;

            return reporte;
        }
    }
}
