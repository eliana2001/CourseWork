using BloomTrack.Connection;
using BloomTrack.Models;
using BloomTrack.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace Tests
{
    public class AuthServiceTests
    {
        private ContextDb CreateInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<ContextDb>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ContextDb(options);
        }
        private JwtService CreateJwtService()
        {
            var inMemorySettings = new Dictionary<string, string> {
                { "JwtSettings:SecretKey", "TestSecretKeyForTesting1234567890" }
            };

            IConfiguration configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();

            return new JwtService(configuration);
        }

        [Fact]
        public async Task Register_DuplicateLogin_ReturnsBadRequest()
        {
            var context = CreateInMemoryContext();
            var jwtService = CreateJwtService();
            var authService = new AuthService(context, jwtService);

            context.Users.Add(new User
            {
                Login = "Dmitry123",
                Password = "pass123",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.RegisterRequest
            {
                Login = "Dmitry123",
                Password = "newpass",
                Email = "new@test.com",
                FullName_User = "Новый"
            };
            var result = await authService.Register(request);
            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }

        [Fact]
        public async Task Login_WrongPassword_ReturnsBadRequest()
        {
            var context = CreateInMemoryContext();
            var jwtService = CreateJwtService();
            var authService = new AuthService(context, jwtService);

            context.Users.Add(new User
            {
                Login = "Dmitry123",
                Password = "correctpass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.LoginRequest
            {
                Login = "Dmitry123",
                Password = "wrongpass"
            };

            var result = await authService.Login(request);
            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }
    }
}