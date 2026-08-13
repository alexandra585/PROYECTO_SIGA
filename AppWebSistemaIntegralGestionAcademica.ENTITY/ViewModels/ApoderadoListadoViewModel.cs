using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class ApoderadoListadoViewModel
    {
        public List<ApoderadoViewModel> Apoderados { get; set; } 
            = new List<ApoderadoViewModel>();

        public PaginacionViewModel Paginacion { get; set; } 
            = new PaginacionViewModel();

        public string? Nombre { get; set; }
        public string? Email { get; set; }
        public string? Dni { get; set; }
        public string? Telefono { get; set; }
        public string? Direccion { get; set; }
        public int? CantidadHijos { get; set; }
        public bool? Activo { get; set; }
    }
}
