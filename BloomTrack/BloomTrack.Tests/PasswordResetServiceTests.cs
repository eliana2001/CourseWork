using BloomTrack.Connection;
using BloomTrack.Models;
using BloomTrack.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace Tests
{
    public class PasswordResetServiceTests
    {
        private ContextDb CreateInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<ContextDb>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ContextDb(options);
        }

        private EmailService CreateTestEmailService()
        {
            var inMemorySettings = new Dictionary<string, string>
            {
                { "SmtpSettings:Host", "smtp.test.com" },
                { "SmtpSettings:Port", "587" }
            };
            IConfiguration configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();
            return new EmailService(configuration);
        }

        [Fact]
        public async Task RequestResetCode_UserNotFound_ReturnsBadRequest()
        {
            var context = CreateInMemoryContext();
            var emailService = CreateTestEmailService();
            var service = new PasswordResetService(context, emailService);

            var request = new BloomTrack.Requests.RequestCodeRequest
            { Email = "nonexistent@test.com" };

            var result = await service.RequestResetCode(request);

            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }

        [Fact]
        public async Task VerifyCode_ExpiredCode_ReturnsBadRequest()
        {
            var context = CreateInMemoryContext();
            var emailService = CreateTestEmailService();
            var service = new PasswordResetService(context, emailService);

            context.PasswordResetCodes.Add(new PasswordResetCode
            {
                Id_Code = 1,
                Email = "test@test.com",
                Code = "123456",
                ExpiresAt = DateTime.UtcNow.AddMinutes(-10),
                IsUsed = false
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.VerifyCodeRequest
            { Email = "test@test.com", Code = "123456" };

            var result = await service.VerifyCode(request);

            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }

        [Fact]
        public async Task ResetPassword_ShortPassword_ReturnsBadRequest()
        {

            var context = CreateInMemoryContext();
            var emailService = CreateTestEmailService();
            var service = new PasswordResetService(context, emailService);


            context.PasswordResetCodes.Add(new PasswordResetCode
            {
                Id_Code = 1,
                Email = "test@test.com",
                Code = "123456",
                ExpiresAt = DateTime.UtcNow.AddMinutes(10),
                IsUsed = false
            });
            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "oldpass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.ResetPasswordRequest
            { Email = "test@test.com", Code = "123456", NewPassword = "123" };

            var result = await service.ResetPassword(request);

            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }
    }
}