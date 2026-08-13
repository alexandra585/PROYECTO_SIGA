using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class UsuarioListadoViewModel
    {
        public List<UsuarioViewModel> Usuarios { get; set; }
            = new List<UsuarioViewModel>();

        public PaginacionViewModel Paginacion { get; set; }
            = new PaginacionViewModel();

        // =========================
        // FILTROS
        // =========================

        public string? Nombre { get; set; }

        public string? Email { get; set; }

        public string? Rol { get; set; }

        public bool? Activo { get; set; }
    }
}
