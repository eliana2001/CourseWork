using System.Runtime.ConstrainedExecution;

namespace BloomTrack.Services
{
    public class EmailService
    {
        private readonly IConfiguration _configuration;
        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public async Task SendPasswordResetCodeAsync(string email, string code)
        {
            Console.WriteLine($"\nКод подтверждения");
            Console.WriteLine($"Email: {email}");
            Console.WriteLine($"Код: {code}");
            Console.WriteLine($"Время {DateTime.Now}");
            Console.WriteLine($"\nКод подтверждения");

        }
    }
}
