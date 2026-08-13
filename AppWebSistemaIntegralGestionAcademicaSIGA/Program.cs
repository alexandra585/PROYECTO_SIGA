using AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Extensions;
using AppWebSistemaIntegralGestionAcademicaSIGA.WEB.Hubs;

var builder = WebApplication.CreateBuilder(args);

// AGREGAR SERVICIOS AL CONTENEDOR.
builder.Services.AddControllersWithViews();

// REGISTRAR RUNTIME PARA ACTUALIZAR LAS PAGINAS CSHTML
builder.Services.AddRazorPages().AddRazorRuntimeCompilation();

// CONFIGURAR EL APP DATABASE CONTEXT
builder.Services.AddDatabaseContext(builder.Configuration);

// REGISTRAR LOS REPOSITORIOS
builder.Services.AddRepositories();

// REGISTRAR EL SIGNALR
builder.Services.AddSignalR();

// AGREGAR SESSIONS
builder.Services.Session();

var app = builder.Build();

// CONFIGURAR LA CANALIZACIÓN DE SOLICITUDES HTTP.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles(); // NUEVO

app.UseRouting();

app.UseSession(); // NUEVO

app.UseAuthorization();

app.MapHub<ChatHub>("/chathub"); // NUEVO

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Inicio}/{action=Inicio}/{id?}");

app.Run();
