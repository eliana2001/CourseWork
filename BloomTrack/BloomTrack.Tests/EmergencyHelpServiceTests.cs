using BloomTrack.Connection;
using BloomTrack.Models;
using BloomTrack.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace Tests
{
    public class EmergencyHelpServiceTests
    {
        private ContextDb CreateInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<ContextDb>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ContextDb(options);
        }

        [Fact]
        public async Task GetDiagnosisHistory_ByUserId_ReturnsList()
        {
            var context = CreateInMemoryContext();
            var service = new EmergencyHelpService(context);

            context.Users.Add(new User
            {
                Id_User = 3,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            context.DiagnosisResults.Add(new DiagnosisResult
            {
                Id_Result = 1,
                Id_User = 3,
                Id_Plant = 1,
                Id_Problem = 1,
                Date_Diagnostic = DateTime.UtcNow,
                Description = "Диагноз: хлороз" 
            });
            await context.SaveChangesAsync();

            var result = await service.GetDiagnosisHistory(3);

            Assert.IsType<Microsoft.AspNetCore.Mvc.OkObjectResult>(result);
        }

        [Fact]
        public async Task SubmitDiagnosis_WrongPlantOwner_ReturnsNotFound()
        {
            var context = CreateInMemoryContext();
            var service = new EmergencyHelpService(context);

            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            context.Users.Add(new User
            {
                Id_User = 2,
                Login = "other",
                Password = "pass",
                Email = "other@test.com",
                FullName_User = "Другой"
            });
            context.Plants.Add(new Plant
            {
                Id_Plant = 1,
                Name_Plant = "Тест",
                Id_User = 2
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.DiagnosisRequest
            {
                Id_Plant = 1,
                Id_Problem = 1
            };
            var result = await service.SubmitDiagnosis(request, 1);
            Assert.IsType<Microsoft.AspNetCore.Mvc.NotFoundObjectResult>(result);
        }
    }
}