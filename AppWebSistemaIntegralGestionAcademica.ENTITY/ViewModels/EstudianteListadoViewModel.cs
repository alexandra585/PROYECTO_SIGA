using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class EstudianteListadoViewModel
    {
        public List<EstudianteViewModel> Estudiantes { get; set; }
            = new List<EstudianteViewModel>();

        public PaginacionViewModel Paginacion { get; set; }
            = new PaginacionViewModel();

        // =========================
        // FILTROS
        // =========================

        public string? Nombre { get; set; }

        public string? Email { get; set; }

        public string? CodigoEstudiante { get; set; }

        public string? NombreCarrera { get; set; }

        public int? SemestreActual { get; set; }

        public bool? Activo { get; set; }
    }
}
