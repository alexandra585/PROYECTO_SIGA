using System;
using System.Collections.Generic;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.ENTITY.ViewModels
{
    public class PaginacionViewModel
    {
        public int Pagina { get; set; }

        public int TamanioPagina { get; set; }

        public int TotalRegistros { get; set; }

        public int TotalPaginas
        {
            get
            {
                return (int)Math.Ceiling(
                    (double)TotalRegistros / TamanioPagina
                );
            }
        }

        public bool TienePaginaAnterior
        {
            get
            {
                return Pagina > 1;
            }
        }

        public bool TienePaginaSiguiente
        {
            get
            {
                return Pagina < TotalPaginas;
            }
        }
    }
}
