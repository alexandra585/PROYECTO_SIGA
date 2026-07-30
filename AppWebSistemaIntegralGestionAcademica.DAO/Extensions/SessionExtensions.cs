using Microsoft.Extensions.DependencyInjection;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Extensions
{
    public static class SessionExtensions
    {
        public static IServiceCollection Session(this IServiceCollection services)
        {
            services.AddDistributedMemoryCache();
            services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(30);
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
                options.Cookie.Name = "SIGA.Session";
            });

            services.AddHttpContextAccessor();

            return services;
        }
    }
}
