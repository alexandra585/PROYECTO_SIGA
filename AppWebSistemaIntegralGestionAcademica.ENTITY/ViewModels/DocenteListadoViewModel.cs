using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class DocenteListadoViewModel
    {
        public List<DocenteViewModel> Docentes { get; set; }
            = new List<DocenteViewModel>();

        public PaginacionViewModel Paginacion { get; set; }
            = new PaginacionViewModel();

        public string? Nombre { get; set; }

        public string? Email { get; set; }

        public string? Especialidad { get; set; }

        public string? GradoAcademico { get; set; }

        public bool? Activo { get; set; }
    }
}
