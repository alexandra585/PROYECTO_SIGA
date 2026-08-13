using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class SecretariaListadoViewModel
    {
        public List<SecretariaViewModel> Secretarias { get; set; }
            = new List<SecretariaViewModel>();

        public PaginacionViewModel Paginacion { get; set; }
            = new PaginacionViewModel();

        // =========================
        // FILTROS
        // =========================

        public string? Nombre { get; set; }

        public string? Email { get; set; }

        public string? Cargo { get; set; }

        public string? Telefono { get; set; }

        public bool? Activo { get; set; }
    }
}
