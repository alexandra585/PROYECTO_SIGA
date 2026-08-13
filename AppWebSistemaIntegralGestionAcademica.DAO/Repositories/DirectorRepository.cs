using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Constants;
using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Repositories
{
    public class DirectorRepository : AppBaseRepository, IDirectorRepository
    {
        public DirectorRepository(IConfiguration configuration) : base(configuration) { }

        public async Task<DirectorDashboardViewModel> DirectorDashboard()
        {
            var model = new DirectorDashboardViewModel();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_DirectorDashboard", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            model.TotalEstudiantes = reader.GetInt32(reader.GetOrdinal("totalEstudiantes"));
                            model.TotalDocentes = reader.GetInt32(reader.GetOrdinal("totalDocentes"));
                            model.TotalCursos = reader.GetInt32(reader.GetOrdinal("totalCursos"));
                            model.TotalSecretarias = reader.GetInt32(reader.GetOrdinal("totalSecretarias"));
                            model.TotalApoderados = reader.GetInt32(reader.GetOrdinal("totalApoderados"));
                            model.TotalMatriculasActivas = reader.GetInt32(reader.GetOrdinal("totalMatriculasActivas"));
                            model.PeriodoActivo = reader.GetString(reader.GetOrdinal("periodoActivo"));
                        }
                    }
                }
            }
            return model;
        }

        public async Task<List<PeriodoAcademico>> PeriodoAcademico()
        {
            var periodos = new List<PeriodoAcademico>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_PeriodoAcademico", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            periodos.Add(new PeriodoAcademico
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombrePeriodo = reader.GetString(reader.GetOrdinal("nombrePeriodo")),
                                esActivo = reader.GetBoolean(reader.GetOrdinal("esActivo"))
                            });
                        }
                    }
                }
            }
            return periodos;
        }

        public async Task<List<CursoDocenteEstudiante>> CursoDocente()
        {
            var cursos = new List<CursoDocenteEstudiante>();

            using (SqlConnection conn = GetConnection())
            {
                await conn.OpenAsync();

                using (SqlCommand cmd = new SqlCommand("usp_CursoDocente", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            cursos.Add(new CursoDocenteEstudiante
                            {
                                id = reader.GetInt32(reader.GetOrdinal("id")),
                                nombreCurso = reader.GetString(reader.GetOrdinal("nombreCurso")),
                                codigoCurso = reader.GetString(reader.GetOrdinal("codigoCurso")),
                                nombreDocente = reader.GetString(reader.GetOrdinal("NombreDocente")),
                                nombrePeriodo = reader.GetString(reader.GetOrdinal("nombrePeriodo"))
                            });
                        }
                    }
                }
            }
            return cursos;
        }
    }
}