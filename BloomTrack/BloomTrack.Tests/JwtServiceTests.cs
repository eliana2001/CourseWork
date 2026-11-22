using BloomTrack.Models;
using BloomTrack.Services;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace Tests
{
    public class JwtServiceTests
    {
        private JwtService CreateJwtService()
        {
            var inMemorySettings = new Dictionary<string, string>
            {
                { "JwtSettings:SecretKey", "TestSecretKeyForTesting1234567890" }
            };

            IConfiguration configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();

            return new JwtService(configuration);
        }

        [Fact]
        public void CreateToken_ValidUser_ReturnsToken()
        {
            var jwtService = CreateJwtService();
            var user = new User
            {
                Id_User = 1,
                Login = "testuser",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            };
            var token = jwtService.CreateToken(user);
            Assert.NotNull(token);
            Assert.NotEmpty(token);
        }
    }
}