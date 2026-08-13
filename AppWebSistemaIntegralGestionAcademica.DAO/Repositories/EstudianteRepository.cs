using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class EstudianteRepository : AppBaseRepository, IEstudianteRepository
    {
        public EstudianteRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<EstudianteDashboardViewModel> EstudianteDashboard(int usuarioId)
        {
            var model = new EstudianteDashboardViewModel
            {
                CursosMatriculados = new List<CursoMatriculado>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_EstudianteDashboard", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@usuarioId", usuarioId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.nombreCompleto = Convert.ToString(reader["nombreCompleto"]) ?? string.Empty;
                            model.codigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? string.Empty;
                            model.nombreCarrera = Convert.ToString(reader["nombreCarrera"]) ?? string.Empty;
                            model.semestreActual = Convert.ToInt32(reader["semestreActual"]);
                        }

                        await reader.NextResultAsync();

                        while (await reader.ReadAsync())
                        {
                            double notaFinal = Convert.ToDouble(reader["NotaFinal"]);
                            string estadoMatricula = Convert.ToString(reader["estado"]) ?? string.Empty;

                            string estadoNota = "";

                            if (estadoMatricula == "Retirado")
                                estadoNota = "Retirado";
                            else if (notaFinal >= 13)
                                estadoNota = "Aprobado";
                            else if (notaFinal > 0 && notaFinal < 13)
                                estadoNota = "Desaprobado";
                            else
                                estadoNota = "Sin notas";

                            model.CursosMatriculados.Add(new CursoMatriculado
                            {
                                matriculaId = reader.GetInt32(reader.GetOrdinal("MatriculaId")),
                                cursoDocenteId = reader.GetInt32(reader.GetOrdinal("cursoDocenteId")),
                                nombreCurso = reader.GetString(reader.GetOrdinal("nombreCurso")),
                                codigoCurso = reader.GetString(reader.GetOrdinal("codigoCurso")),

                                estado = estadoMatricula,
                                notaFinal = notaFinal,
                                estadoNota = estadoNota
                            });
                        }
                    }
                }
            }

            model.promedioGeneral = await CalcularPromedioGeneral(usuarioId);

            return model;
        }

        private async Task<double> CalcularPromedioGeneral(int estudianteId)
        {
            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CalcularPromedioGeneralEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);

                    object result = await cmd.ExecuteScalarAsync();
                    return result != DBNull.Value ? Convert.ToDouble(result) : 0;
                }
            }
        }

        public async Task<List<CursoEstudianteNotaViewModel>> MisCursos(int estudianteId)
        {
            var cursos = new List<CursoEstudianteNotaViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_MisCursos", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            cursos.Add(new CursoEstudianteNotaViewModel
                            {
                                MatriculaId = Convert.ToInt32(reader["MatriculaId"]),
                                CursoId = Convert.ToInt32(reader["CursoId"]),
                                CodigoCurso = Convert.ToString(reader["codigoCurso"]) ?? string.Empty,
                                NombreCurso = Convert.ToString(reader["nombreCurso"]) ?? string.Empty,
                                Creditos = Convert.ToInt32(reader["creditos"]),
                                CursoDocenteId = Convert.ToInt32(reader["CursoDocenteId"]),
                                NombreDocente = Convert.ToString(reader["NombreDocente"]) ?? string.Empty,
                                EstadoMatricula = Convert.ToString(reader["EstadoMatricula"]) ?? string.Empty,
                                PromedioActual = Convert.ToDouble(reader["PromedioActual"])
                            });
                        }
                    }
                }
            }
            return cursos;
        }

        public async Task<List<NotaDetalleViewModel>> MisNotasCursos(int matriculaId)
        {
            var notas = new List<NotaDetalleViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_MisNotasCursos", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@matriculaId", matriculaId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            notas.Add(new NotaDetalleViewModel
                            {
                                EvaluacionId = Convert.ToInt32(reader["EvaluacionId"]),
                                TipoEvaluacion = Convert.ToString(reader["TipoEvaluacion"]) ?? string.Empty,
                                FechaEvaluacion = Convert.ToDateTime(reader["fechaEvaluacion"]),
                                PesoPorcentual = Convert.ToDecimal(reader["notaPorcentual"]),
                                NotaObtenida = Convert.ToDecimal(reader["NotaObtenida"]),
                                Observacion = reader["observacion"] != DBNull.Value ? Convert.ToString(reader["observacion"]) : null,
                                FechaRegistro = reader["fechaRegistro"] != DBNull.Value ? Convert.ToDateTime(reader["fechaRegistro"]) : (DateTime?)null
                            });
                        }
                    }
                }
            }
            return notas;
        }

        public async Task<List<ResumenNotaViewModel>> ResumenNotas(int estudianteId)
        {
            var resumen = new List<ResumenNotaViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ResumenNotas", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            resumen.Add(new ResumenNotaViewModel
                            {
                                CursoId = Convert.ToInt32(reader["CursoId"]),
                                CodigoCurso = Convert.ToString(reader["codigoCurso"]) ?? string.Empty,
                                NombreCurso = Convert.ToString(reader["nombreCurso"]) ?? string.Empty,
                                Creditos = Convert.ToInt32(reader["creditos"]),
                                PromedioFinal = Convert.ToDouble(reader["PromedioFinal"]),
                                Estado = Convert.ToString(reader["Estado"]) ?? string.Empty
                            });
                        }
                    }
                }
            }
            return resumen;
        }

        public async Task<List<AsistenciaEstudianteViewModel>> MisAsistencias(int estudianteId)
        {
            var asistencias = new List<AsistenciaEstudianteViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_MisAsistencias", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            asistencias.Add(new AsistenciaEstudianteViewModel
                            {
                                NombreCurso = reader.GetString(reader.GetOrdinal("nombreCurso")),
                                CodigoCurso = reader.GetString(reader.GetOrdinal("codigoCurso")),
                                Fecha = reader.GetDateTime(reader.GetOrdinal("fecha")),
                                Estado = reader.GetString(reader.GetOrdinal("estado")),
                                Observacion = reader.IsDBNull(reader.GetOrdinal("observacion")) ? null : reader.GetString(reader.GetOrdinal("observacion")),
                                HoraRegistro = reader.IsDBNull(reader.GetOrdinal("horaRegistro")) ? null : reader.GetTimeSpan(reader.GetOrdinal("horaRegistro"))
                            });
                        }
                    }
                }
            }
            return asistencias;
        }

        public async Task<ReporteAcademicoViewModel> ReporteAcademico(int estudianteId)
        {
            var reporte = new ReporteAcademicoViewModel
            {
                Cursos = new List<ResumenNotaViewModel>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ReporteAcademico", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            reporte.NombreCompleto = Convert.ToString(reader["nombreCompleto"]) ?? string.Empty;
                            reporte.Email = Convert.ToString(reader["email"]) ?? string.Empty;
                            reporte.CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? string.Empty;
                            reporte.Carrera = Convert.ToString(reader["nombreCarrera"]) ?? string.Empty;
                            reporte.SemestreActual = Convert.ToInt32(reader["semestreActual"]);
                        }

                        await reader.NextResultAsync();

                        while (await reader.ReadAsync())
                        {
                            reporte.Cursos.Add(new ResumenNotaViewModel
                            {
                                CursoId = Convert.ToInt32(reader["CursoId"]),
                                CodigoCurso = Convert.ToString(reader["codigoCurso"]) ?? string.Empty,
                                NombreCurso = Convert.ToString(reader["nombreCurso"]) ?? string.Empty,
                                Creditos = Convert.ToInt32(reader["creditos"]),
                                PromedioFinal = Convert.ToDouble(reader["PromedioFinal"]),
                                Estado = Convert.ToString(reader["Estado"]) ?? string.Empty
                            });
                        }
                    }
                }
            }

            double suma = 0;
            int count = 0;
            foreach (var curso in reporte.Cursos)
            {
                if (curso.PromedioFinal > 0)
                {
                    suma += curso.PromedioFinal;
                    count++;
                }
            }
            reporte.PromedioGeneral = count > 0 ? suma / count : 0;
            reporte.TotalCreditosAprobados = reporte.Cursos
                .Where(c => c.Estado == "Aprobado")
                .Sum(c => c.Creditos);

            return reporte;
        }
    }
}
