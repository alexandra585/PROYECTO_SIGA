using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class ApoderadoRepository : AppBaseRepository, IApoderadoRepository
    {
        public ApoderadoRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<ApoderadoDashboardViewModel> ApoderadoDashboard(int apoderadoId)
        {
            var model = new ApoderadoDashboardViewModel
            {
                Hijos = new List<ApoderadoHijoViewModel>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ApoderadoDashboard", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@apoderadoId", apoderadoId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.NombreApoderado = Convert.ToString(reader["nombreCompleto"]) ?? "";
                        }

                        await reader.NextResultAsync();

                        if (await reader.ReadAsync())
                        {
                            model.PeriodoActivo = Convert.ToString(reader["nombrePeriodo"]) ?? "No definido";
                        }

                        await reader.NextResultAsync();

                        while (await reader.ReadAsync())
                        {
                            model.Hijos.Add(new ApoderadoHijoViewModel
                            {
                                EstudianteId = Convert.ToInt32(reader["EstudianteId"]),
                                NombreCompleto = Convert.ToString(reader["NombreCompleto"]) ?? "",
                                CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? "",
                                Parentesco = Convert.ToString(reader["parentesco"]) ?? ""
                            });
                        }
                    }
                }
            }

            model.TotalHijos = model.Hijos.Count;
            return model;
        }

        public async Task<List<ApoderadoHijoViewModel>> ListHijos(int apoderadoId)
        {
            var lista = new List<ApoderadoHijoViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ListHijos", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@apoderadoId", apoderadoId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            lista.Add(new ApoderadoHijoViewModel
                            {
                                EstudianteId = Convert.ToInt32(reader["EstudianteId"]),
                                NombreCompleto = Convert.ToString(reader["nombreCompleto"]) ?? "",
                                CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? "",
                                Parentesco = Convert.ToString(reader["parentesco"]) ?? ""
                            });
                        }
                    }
                }
            }

            return lista;
        }

        public async Task<List<PeriodoAcademico>> ListPeriodos()
        {
            var lista = new List<PeriodoAcademico>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ListPeriodos", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            lista.Add(new PeriodoAcademico
                            {
                                id = Convert.ToInt32(reader["id"]),
                                nombrePeriodo = Convert.ToString(reader["nombrePeriodo"]) ?? "",
                                esActivo = Convert.ToBoolean(reader["esActivo"])
                            });
                        }
                    }
                }
            }

            return lista;
        }

        public async Task<ApoderadoLibretaViewModel> LibretaNotas(int apoderadoId, int estudianteId, int? periodoId)
        {
            var model = new ApoderadoLibretaViewModel
            {
                EstudianteId = estudianteId,
                Periodos = new List<ApoderadoPeriodoNotasViewModel>()
            };

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_ValidarEstudiante", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@apoderadoId", apoderadoId);
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (!await reader.ReadAsync())
                        {
                            return null;
                        }

                        model.NombreEstudiante = Convert.ToString(reader["nombreCompleto"]) ?? "";
                        model.CodigoEstudiante = Convert.ToString(reader["codigoEstudiante"]) ?? "";
                        model.Parentesco = Convert.ToString(reader["parentesco"]) ?? "";
                    }
                }

                var periodos = new Dictionary<int, ApoderadoPeriodoNotasViewModel>();

                using (SqlCommand cmd = new SqlCommand("usp_LibretaNotas", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@estudianteId", estudianteId);
                    cmd.Parameters.AddWithValue("@periodoId", (object?)periodoId ?? DBNull.Value);

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            int pId = Convert.ToInt32(reader["periodoId"]);
                            string nombrePeriodo = Convert.ToString(reader["nombrePeriodo"]) ?? "";
                            bool esActivo = Convert.ToBoolean(reader["esActivo"]);
                            string codigoCurso = Convert.ToString(reader["codigoCurso"]) ?? "";
                            string nombreCurso = Convert.ToString(reader["nombreCurso"]) ?? "";
                            string nombreDocente = Convert.ToString(reader["nombreDocente"]) ?? "";

                            if (!periodos.TryGetValue(pId, out var periodoVM))
                            {
                                periodoVM = new ApoderadoPeriodoNotasViewModel
                                {
                                    PeriodoId = pId,
                                    NombrePeriodo = nombrePeriodo,
                                    EsActivo = esActivo,
                                    Cursos = new List<ApoderadoCursoNotasViewModel>()
                                };
                                periodos[pId] = periodoVM;
                            }

                            var cursoVM = periodoVM.Cursos.FirstOrDefault(c => c.CodigoCurso == codigoCurso);
                            if (cursoVM == null)
                            {
                                cursoVM = new ApoderadoCursoNotasViewModel
                                {
                                    CodigoCurso = codigoCurso,
                                    NombreCurso = nombreCurso,
                                    NombreDocente = nombreDocente,
                                    Notas = new List<ApoderadoNotaDetalleViewModel>()
                                };
                                periodoVM.Cursos.Add(cursoVM);
                            }

                            if (!reader.IsDBNull(reader.GetOrdinal("nota")))
                            {
                                cursoVM.Notas.Add(new ApoderadoNotaDetalleViewModel
                                {
                                    TipoEvaluacion = reader.IsDBNull(reader.GetOrdinal("tipoEvaluacion")) ? "" : Convert.ToString(reader["tipoEvaluacion"]) ?? "",
                                    Nota = Convert.ToDecimal(reader["nota"]),
                                    Peso = reader.IsDBNull(reader.GetOrdinal("peso")) ? null : Convert.ToDecimal(reader["peso"]),
                                    FechaEvaluacion = reader.IsDBNull(reader.GetOrdinal("fechaEvaluacion")) ? null : Convert.ToDateTime(reader["fechaEvaluacion"])
                                });
                            }
                        }
                    }
                }

                foreach (var periodo in periodos.Values)
                {
                    foreach (var curso in periodo.Cursos)
                    {
                        if (curso.Notas.Any(n => n.Nota.HasValue))
                        {
                            curso.Promedio = curso.Notas
                                .Where(n => n.Nota.HasValue)
                                .Average(n => n.Nota.Value);
                        }
                    }
                }

                model.Periodos = periodos.Values
                    .OrderByDescending(p => p.EsActivo)
                    .ThenByDescending(p => p.PeriodoId)
                    .ToList();
            }

            return model;
        }
    }
}
