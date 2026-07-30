using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Interfaces;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Filters;
using Microsoft.AspNetCore.Mvc;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using System.Drawing;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Controllers
{
    [AutorizationRoleFilter("Estudiante")]
    public class EstudianteController : Controller
    {
        private readonly IEstudianteRepository _estudianteRepository;

        public EstudianteController(IEstudianteRepository estudianteRepository)
        {
            _estudianteRepository = estudianteRepository;
        }

        // ========================
        // DASHBOARD DEL ESTUDIANTE
        // ========================
        [HttpGet]
        public async Task<IActionResult> Dashboard()
        {
            if (HttpContext.Session.GetString("Rol") != "Estudiante")
            {
                return RedirectToAction("IniciarSesion", "Auth");
            }

            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var model = await _estudianteRepository.EstudianteDashboard(usuarioId);

            return View(model);
        }

        // ==========
        // MIS CURSOS
        // ==========
        [HttpGet]
        public async Task<IActionResult> MisCursos()
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var cursos = await _estudianteRepository.MisCursos(usuarioId);
            return View(cursos);
        }

        // =========
        // MIS NOTAS
        // =========
        [HttpGet]
        public async Task<IActionResult> MisNotas(int? matriculaId)
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;

            if (!matriculaId.HasValue)
            {
                var resumen = await _estudianteRepository.ResumenNotas(usuarioId);
                return View("ResumenNotas", resumen);
            }

            var notas = await _estudianteRepository.MisNotasCursos(matriculaId.Value);
            ViewBag.MatriculaId = matriculaId.Value;
            return View(notas);
        }

        // ===============
        // MIS ASISTENCIAS
        // ===============
        [HttpGet]
        public async Task<IActionResult> MisAsistencias()
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var asistencias = await _estudianteRepository.MisAsistencias(usuarioId);
            return View(asistencias);
        }

        // =================
        // REPORTE ACADÉMICO
        // =================
        [HttpGet]
        public async Task<IActionResult> ReporteAcademico()
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var reporte = await _estudianteRepository.ReporteAcademico(usuarioId);
            return View(reporte);
        }

        // ========================
        // EXPORTAR REPORTE A EXCEL
        // ========================
        [HttpGet]
        public async Task<IActionResult> ExportarReporteExcel()
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var reporte = await _estudianteRepository.ReporteAcademico(usuarioId);

            using (ExcelPackage package = new ExcelPackage())
            {
                ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("ReporteAcademico");

                // TÍTULO PRINCIPAL
                worksheet.Cells[1, 1].Value = "REPORTE ACADÉMICO";
                worksheet.Cells[1, 1, 1, 6].Merge = true;
                worksheet.Cells[1, 1].Style.Font.Size = 18;
                worksheet.Cells[1, 1].Style.Font.Bold = true;
                worksheet.Cells[1, 1].Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;

                int row = 3;

                // DATOS DEL ESTUDIANTE
                worksheet.Cells[row, 1].Value = "DATOS DEL ESTUDIANTE";
                worksheet.Cells[row, 1, row, 6].Merge = true;
                worksheet.Cells[row, 1].Style.Font.Bold = true;
                worksheet.Cells[row, 1].Style.Fill.PatternType = ExcelFillStyle.Solid;
                worksheet.Cells[row, 1].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
                row++;

                worksheet.Cells[row, 1].Value = "Nombre Completo:";
                worksheet.Cells[row, 2].Value = reporte.NombreCompleto;
                worksheet.Cells[row, 4].Value = "Código:";
                worksheet.Cells[row, 5].Value = reporte.CodigoEstudiante;
                row++;

                worksheet.Cells[row, 1].Value = "Email:";
                worksheet.Cells[row, 2].Value = reporte.Email;
                worksheet.Cells[row, 4].Value = "Semestre:";
                worksheet.Cells[row, 5].Value = reporte.SemestreActual;
                row++;

                worksheet.Cells[row, 1].Value = "Carrera:";
                worksheet.Cells[row, 2].Value = reporte.Carrera;
                worksheet.Cells[row, 4].Value = "Créditos Aprobados:";
                worksheet.Cells[row, 5].Value = reporte.TotalCreditosAprobados;
                row++;

                worksheet.Cells[row, 1].Value = "Promedio General:";
                worksheet.Cells[row, 2].Value = reporte.PromedioGeneral.ToString("F2");
                worksheet.Cells[row, 2].Style.Font.Bold = true;
                worksheet.Cells[row, 2].Style.Font.Color.SetColor(Color.Green);
                row += 2;

                // RESUMEN DE NOTAS POR CURSO
                worksheet.Cells[row, 1].Value = "RESUMEN DE NOTAS POR CURSO";
                worksheet.Cells[row, 1, row, 6].Merge = true;
                worksheet.Cells[row, 1].Style.Font.Bold = true;
                worksheet.Cells[row, 1].Style.Fill.PatternType = ExcelFillStyle.Solid;
                worksheet.Cells[row, 1].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
                row++;

                // ENCABEZADOS DE TABLA
                worksheet.Cells[row, 1].Value = "Código";
                worksheet.Cells[row, 2].Value = "Curso";
                worksheet.Cells[row, 3].Value = "Créditos";
                worksheet.Cells[row, 4].Value = "Promedio Final";
                worksheet.Cells[row, 5].Value = "Estado";

                for (int i = 1; i <= 5; i++)
                {
                    worksheet.Cells[row, i].Style.Font.Bold = true;
                    worksheet.Cells[row, i].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    worksheet.Cells[row, i].Style.Fill.BackgroundColor.SetColor(Color.LightBlue);
                    worksheet.Cells[row, i].Style.Border.BorderAround(ExcelBorderStyle.Thin);
                }
                row++;

                // DATOS DE CURSOS
                foreach (var curso in reporte.Cursos)
                {
                    worksheet.Cells[row, 1].Value = curso.CodigoCurso;
                    worksheet.Cells[row, 2].Value = curso.NombreCurso;
                    worksheet.Cells[row, 3].Value = curso.Creditos;
                    worksheet.Cells[row, 4].Value = curso.PromedioFinal > 0 ? curso.PromedioFinal.ToString("F2") : "--";
                    worksheet.Cells[row, 5].Value = curso.Estado;

                    if (curso.Estado == "Aprobado")
                    {
                        worksheet.Cells[row, 5].Style.Fill.PatternType = ExcelFillStyle.Solid;
                        worksheet.Cells[row, 5].Style.Fill.BackgroundColor.SetColor(Color.LightGreen);
                    }
                    else if (curso.Estado == "Desaprobado")
                    {
                        worksheet.Cells[row, 5].Style.Fill.PatternType = ExcelFillStyle.Solid;
                        worksheet.Cells[row, 5].Style.Fill.BackgroundColor.SetColor(Color.LightCoral);
                    }

                    row++;
                }

                // PIE DE PÁGINA
                row += 2;
                worksheet.Cells[row, 1].Value = $"Reporte generado el: {DateTime.Now:dd/MM/yyyy HH:mm:ss}";
                worksheet.Cells[row, 1, row, 6].Merge = true;
                worksheet.Cells[row, 1].Style.Font.Italic = true;

                worksheet.Cells.AutoFitColumns();

                byte[] bytes = package.GetAsByteArray();
                string fileName = $"RA_{reporte.NombreCompleto}_{reporte.CodigoEstudiante}_{DateTime.Now:dd/MM/yyyy}.xlsx";

                return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
            }
        }

        // ======================
        // EXPORTAR REPORTE A PDF
        // ======================
        [HttpGet]
        public async Task<IActionResult> ExportarReportePDF()
        {
            int usuarioId = HttpContext.Session.GetInt32("UsuarioId") ?? 0;
            var reporte = await _estudianteRepository.ReporteAcademico(usuarioId);
            return View("ReporteAcademicoPDF", reporte);
        }
    }
}
