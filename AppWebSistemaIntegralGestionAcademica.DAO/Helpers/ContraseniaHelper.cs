using System.Security.Cryptography;
using System.Text;

namespace AppWebSistemaIntegralGestionAcademicaSIGA.DAO.Helpers
{
    public static class ContraseniaHelper
    {
        public static string EncriptarContrasenia(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        public static bool VerificarContrasenia(string enteredPassword, string storedHash)
        {
            if (string.IsNullOrEmpty(enteredPassword) || string.IsNullOrEmpty(storedHash))
                return false;

            string hashOfEntered = EncriptarContrasenia(enteredPassword);
            return hashOfEntered.Equals(storedHash, StringComparison.OrdinalIgnoreCase);
        }
    }
}