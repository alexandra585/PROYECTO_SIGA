using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.Entities;
using AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels;
using Microsoft.EntityFrameworkCore;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Data
{
    public class AppDatabaseContext : DbContext
    {
        public AppDatabaseContext(DbContextOptions<AppDatabaseContext> options) : base(options)
        {
        }

        public DbSet<Usuarios> Usuarios { get; set; }
        public DbSet<EstudianteViewModel> Estudiantes { get; set; }
        public DbSet<Docente> Docentes { get; set; }
        public DbSet<Curso> Cursos { get; set; }
        public DbSet<PeriodoAcademico> PeriodosAcademicos { get; set; }
        public DbSet<CursoDocente> CursosDocentes { get; set; }
        public DbSet<Matricula> Matriculas { get; set; }
    }
}
