using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;

namespace BloomTrack.Interfaces
{
    public interface IPlantService
    {
        Task<ActionResult> GetAllPlants(int userId);
        Task<ActionResult> GetPlantById(int plantId, int userId);
        Task<ActionResult> CreatePlant(CreatePlantRequest req, int userId);
        Task<ActionResult> UpdatePlant(int plantId, UpdatePlantRequest req, int userId);
        Task<ActionResult> DeletePlant(int plantId, int userId);
        Task<ActionResult> UpdateCare(int plantId, UpdateCareRequest req, int userId);
        Task<ActionResult> GetPlantsStatus(int userId);
        Task<ActionResult> GetPlantHistory(int plantId, int userId);
        Task<ActionResult> AddDiaryEntry(int plantId, DiaryEntryRequest req, int userId);
        Task<ActionResult> GetPlantTypes();
        Task<ActionResult> UploadPlantPhoto(int plantId, IFormFile photo, int userId);

    }
}
