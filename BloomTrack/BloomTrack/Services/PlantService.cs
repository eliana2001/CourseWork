using BloomTrack.Connection;
using BloomTrack.Interfaces;
using BloomTrack.Models;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BloomTrack.Services
{
    public class PlantService : IPlantService
    {
        private readonly ContextDb _context;

        public PlantService(ContextDb context)
        {
            _context = context;
        }

        public async Task<ActionResult> GetAllPlants(int userId)
        {
            var plants = await _context.Plants.Include(p => p.TypePlant).Where(p => p.Id_User == userId).ToListAsync();

            return plants.Count == 0 ? new NotFoundObjectResult("У вас пока нет растений") : new OkObjectResult(plants);
        }

        public async Task<ActionResult> GetPlantById(int plantId, int userId)
        {
            var plant = await _context.Plants.Include(p => p.TypePlant).FirstOrDefaultAsync(p => p.Id_Plant == plantId && p.Id_User == userId);
            return plant == null ? new NotFoundObjectResult("Растение не найдено") : new OkObjectResult(plant);
        }

        public async Task<ActionResult> CreatePlant(CreatePlantRequest req, int userId)
        {
            var typeExists = await _context.TypePlants.AnyAsync(t => t.Id_TypePlant == req.Id_TypePlant);
            if (!typeExists)
                return new BadRequestObjectResult("Указанный вид растения не найден в справочнике");

            var plant = new Plant
            {
                Name_Plant = req.Name_Plant,
                Id_TypePlant = req.Id_TypePlant,
                Id_User = userId,
                DatePurchase = req.DatePurchase,
                PhotoPlant = req.PhotoPlant
            };

            _context.Plants.Add(plant);
            await _context.SaveChangesAsync();

            var createdPlant = await _context.Plants.Include(p => p.TypePlant).FirstOrDefaultAsync(p => p.Id_Plant == plant.Id_Plant);

            return new OkObjectResult(createdPlant);
        }
        public async Task<ActionResult> UpdatePlant(int plantId, UpdatePlantRequest req, int userId)
        {
            var plant = await _context.Plants
                .FirstOrDefaultAsync(p => p.Id_Plant == plantId && p.Id_User == userId);

            if (plant == null)
            {
                return new NotFoundObjectResult(new { message = "Растение не найдено" });
            }

            plant.Name_Plant = req.Name_Plant;
            plant.Id_TypePlant = req.Id_TypePlant;
            plant.DatePurchase = req.DatePurchase;
            plant.PhotoPlant = req.PhotoPlant;

            await _context.SaveChangesAsync();
            return new OkObjectResult(plant);
        }
        public async Task<ActionResult> DeletePlant(int plantId, int userId)
        {
            var plant = await _context.Plants
                .FirstOrDefaultAsync(p => p.Id_Plant == plantId && p.Id_User == userId);

            if (plant == null)
            {
                return new NotFoundObjectResult(new { message = "Растение не найдено" });
            }

            var history = await _context.CareHistories
                .Where(h => h.Id_Plant == plantId)
                .ToListAsync();
            _context.CareHistories.RemoveRange(history);

            _context.Plants.Remove(plant);
            await _context.SaveChangesAsync();

            return new NoContentResult();
        }
        public async Task<ActionResult> AddDiaryEntry(int plantId, DiaryEntryRequest req, int userId)
        {
            var plantExists = await _context.Plants
                .AnyAsync(p => p.Id_Plant == plantId && p.Id_User == userId);

            if (!plantExists)
                return new NotFoundObjectResult(new { message = "Растение не найдено" });

   
            var entry = new CareHistory
            {
                Id_Plant = plantId,
                Id_TypeCare = 5,
                CareDate = DateOnly.FromDateTime(DateTime.UtcNow),
                Notes = req.Note,
                CreatedAt = DateTime.UtcNow
            };

            _context.CareHistories.Add(entry);
            await _context.SaveChangesAsync();

            return new OkObjectResult(entry);
        }
        public async Task<ActionResult> UpdateCare(int plantId, UpdateCareRequest req, int userId)
        {
            var plant = await _context.Plants.FirstOrDefaultAsync(p => p.Id_Plant == plantId && p.Id_User == userId);

            if (plant == null)
                return new NotFoundObjectResult("Растение не найдено");

            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            if (req.LastWateringDate.HasValue && req.LastWateringDate.Value > today)
                return new BadRequestObjectResult("Дата полива не может быть в будущем");

            if (req.LastFertilizingDate.HasValue && req.LastFertilizingDate.Value > today)
                return new BadRequestObjectResult("Дата подкормки не может быть в будущем");

            if (req.LastWateringDate != null)
            {
                plant.LastWateringDate = req.LastWateringDate;
                _context.CareHistories.Add(new CareHistory
                {
                    Id_Plant = plantId,
                    Id_TypeCare = 1, 
                    CareDate = req.LastWateringDate.Value,
                    Notes = req.Notes
                });
            }
            if (req.LastFertilizingDate != null)
            {
                plant.LastFertilizingDate = req.LastFertilizingDate;
                _context.CareHistories.Add(new CareHistory
                {
                    Id_Plant = plantId,
                    Id_TypeCare = 2, 
                    CareDate = req.LastFertilizingDate.Value,
                    Notes = req.Notes
                });
            }

            await _context.SaveChangesAsync();
            return new OkObjectResult(new { message = "Данные об уходе успешно обновлены" });
        }

        public async Task<ActionResult> GetPlantsStatus(int userId)
        {
            var plants = await _context.Plants
                .Include(p => p.TypePlant)
                .Where(p => p.Id_User == userId)
                .ToListAsync();

            var today = DateOnly.FromDateTime(DateTime.UtcNow);

            var result = plants.Select(p => new
            {
                Id = p.Id_Plant,
                Name = p.Name_Plant,
                Type = p.TypePlant.Name_TypePlant,
                // проверка, что дата не null, и кладет её в переменную wDate
                WateringStatus = p.LastWateringDate is DateOnly wDate && p.TypePlant != null ? CalcStatus(wDate, p.TypePlant.WateringIntervalDays, today, "Полив") : "Нет данных о поливе",
                FertilizingStatus = p.LastFertilizingDate is DateOnly fDate && p.TypePlant != null ? CalcStatus(fDate, p.TypePlant.FertilizingIntervalDays, today, "Подкормка") : "Нет данных о подкормке"
            }).ToList();

            return new OkObjectResult(result);
        }
        public async Task<ActionResult> GetPlantHistory(int plantId, int userId)
        {
            var plantExists = await _context.Plants
                .AnyAsync(p => p.Id_Plant == plantId && p.Id_User == userId);

            if (!plantExists)
                return new NotFoundObjectResult("Растение не найдено");

            var history = await _context.CareHistories.Include(ch => ch.TypeCare).Where(ch => ch.Id_Plant == plantId).Select(ch => new
                {
                    Id = ch.Id_CareHistory,
                    TypeName = ch.TypeCare.Name_TypeCare,
                    CareDate = ch.CareDate,
                    Notes = ch.Notes
                })
                .ToListAsync();

            return new OkObjectResult(history);
        }
        public async Task<ActionResult> UploadPlantPhoto(int plantId, IFormFile photo, int userId)
        {
            var plant = await _context.Plants
                .FirstOrDefaultAsync(p => p.Id_Plant == plantId && p.Id_User == userId);

            if (plant == null)
                return new NotFoundObjectResult("Растение не найдено");

            if (photo == null || photo.Length == 0)
                return new BadRequestObjectResult("Файл не выбран");

            //создание папки для того, чтобы фотки перемещались туда
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "plants");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            //удаляем старую фотку
            if (plant.PhotoPlant != null)
            {
                var oldFilePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", plant.PhotoPlant);
                if (File.Exists(oldFilePath))
                    File.Delete(oldFilePath);
            }
            //сохраняем новую
            var fileName = $"plant_{plantId}_{Guid.NewGuid()}{Path.GetExtension(photo.FileName)}";
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {

                await photo.CopyToAsync(stream);
            }


            plant.PhotoPlant = $"/plants/{fileName}";
            plant.LastPhotoDate = DateTime.UtcNow; 
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { photoUrl = plant.PhotoPlant });
        }
        public async Task<ActionResult> GetPlantTypes()
        {
            var types = await _context.TypePlants
                .Select(t => new { t.Id_TypePlant, t.Name_TypePlant })
                .ToListAsync();

            return new OkObjectResult(types);
        }

        private string CalcStatus(DateOnly lastDate, int interval, DateOnly today, string action)
        {
            int daysLeft = lastDate.AddDays(interval).DayNumber - today.DayNumber;
            string statusMessage;
            switch (daysLeft)
            {
                case < 0:
                    statusMessage = $"Просрочено на {-daysLeft} дн.";
                    break;
                case 0:
                    statusMessage = $"Пора выполнить действие, {action.ToLower()} сегодня";
                    break;
                case <= 3:
                    statusMessage = $"{action} через {daysLeft} дн.";
                    break;
                default:
                    statusMessage = $"Всё хорошо, {action.ToLower()} через {daysLeft} дн.";
                    break;
            }
            return statusMessage;
        }
        
    }
}