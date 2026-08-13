using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class CursoListadoViewModel
    {
        public List<CursoViewModel> Cursos { get; set; }
            = new List<CursoViewModel>();

        public PaginacionViewModel Paginacion { get; set; }
            = new PaginacionViewModel();

        public string? CodigoCurso { get; set; }

        public string? NombreCurso { get; set; }

        public int? Creditos { get; set; }

        public int? HorasTeoricas { get; set; }

        public int? HorasPracticas { get; set; }
    }
}
