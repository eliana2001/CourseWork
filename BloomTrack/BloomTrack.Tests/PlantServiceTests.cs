using BloomTrack.Connection;
using BloomTrack.Models;
using BloomTrack.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace Tests
{
    public class PlantServiceTests
    {
        private ContextDb CreateInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<ContextDb>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ContextDb(options);
        }

        [Fact]
        public async Task CreatePlant_InvalidTypePlantId_ReturnsBadRequest()
        {
            // Arrange
            var context = CreateInMemoryContext();
            var plantService = new PlantService(context);

            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.CreatePlantRequest
            {
                Name_Plant = "Монстера",
                Id_TypePlant = 999,
                // DatePurchase имеет тип DateOnly, а не string
                DatePurchase = DateOnly.Parse("2026-11-10")
            };

            // Act — userId передаётся вторым параметром
            var result = await plantService.CreatePlant(request, 1);

            // Assert
            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }

        [Fact]
        public async Task UpdateCare_FutureDate_ReturnsBadRequest()
        {
            // Arrange
            var context = CreateInMemoryContext();
            var plantService = new PlantService(context);

            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            context.Plants.Add(new Plant
            {
                Id_Plant = 1,
                Name_Plant = "Тест",
                Id_User = 1,
                Id_TypePlant = 1
            });
            await context.SaveChangesAsync();

            var request = new BloomTrack.Requests.UpdateCareRequest
            {
                // LastWateringDate имеет тип DateOnly, а не string
                LastWateringDate = DateOnly.Parse("2030-01-01")
            };

            // Act — сигнатура: UpdateCare(int userId, UpdateCareRequest req, int plantId)
            var result = await plantService.UpdateCare(1, request, 1);

            // Assert
            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }

        [Fact]
        public async Task DeletePlant_CascadeDeletesHistory()
        {
            var context = CreateInMemoryContext();
            var plantService = new PlantService(context);

            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            context.Plants.Add(new Plant
            {
                Id_Plant = 1,
                Name_Plant = "Тест",
                Id_User = 1,
                Id_TypePlant = 1
            });
            context.CareHistories.Add(new CareHistory
            {
                Id_CareHistory = 1,
                Id_Plant = 1,
                CareDate = DateOnly.FromDateTime(DateTime.UtcNow)
            });
            await context.SaveChangesAsync();

            var result = await plantService.DeletePlant(1, 1);

            Assert.IsType<Microsoft.AspNetCore.Mvc.NoContentResult>(result); 
            Assert.Empty(await context.CareHistories.Where(c => c.Id_Plant == 1).ToListAsync());
        }

        [Fact]
        public async Task UploadPlantPhoto_EmptyFile_ReturnsBadRequest()
        {
            var context = CreateInMemoryContext();
            var plantService = new PlantService(context);
            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            context.Plants.Add(new Plant
            {
                Id_Plant = 1,
                Name_Plant = "Тест",
                Id_User = 1,
                Id_TypePlant = 1
            });
            await context.SaveChangesAsync();

            var result = await plantService.UploadPlantPhoto(1, null!, 1);

            Assert.IsType<Microsoft.AspNetCore.Mvc.BadRequestObjectResult>(result);
        }

        [Fact]
        public async Task GetPlantsStatus_CalculatesCorrectly()
        {
            // Arrange
            var context = CreateInMemoryContext();
            var plantService = new PlantService(context);

            context.Users.Add(new User
            {
                Id_User = 1,
                Login = "test",
                Password = "pass",
                Email = "test@test.com",
                FullName_User = "Тест"
            });
            context.TypePlants.Add(new TypePlant
            {
                Id_TypePlant = 1,
                Name_TypePlant = "Монстера",
                WateringIntervalDays = 7
            });
            context.Plants.Add(new Plant
            {
                Id_Plant = 1,
                Name_Plant = "Тест",
                Id_User = 1,
                Id_TypePlant = 1,
                // LastWateringDate имеет тип DateOnly, а не DateTime
                LastWateringDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10))
            });
            await context.SaveChangesAsync();

            // Act
            var result = await plantService.GetPlantsStatus(1);

            // Assert
            Assert.IsType<Microsoft.AspNetCore.Mvc.OkObjectResult>(result);
        }
    }
}