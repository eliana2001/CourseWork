using BloomTrack.Interfaces;
using BloomTrack.Requests;
using BloomTrack.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BloomTrack.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PlantController : ControllerBase
    {
        private readonly IPlantService _plantService;

        public PlantController(IPlantService plantService)
        {
            _plantService = plantService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out int userId) ? userId : 0;
        }
        [HttpPost("{id}/photo")]
        [Authorize]
        public async Task<ActionResult> UploadPlantPhoto(int id, IFormFile photo)
        {
            return await _plantService.UploadPlantPhoto(id, photo, GetUserId());
        }

        [HttpGet]
        public async Task<ActionResult> GetMyPlants()
        {
            return await _plantService.GetAllPlants(GetUserId());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult> GetPlant(int id)
        {
            return await _plantService.GetPlantById(id, GetUserId());
        }

        [HttpPost]
        public async Task<ActionResult> CreatePlant([FromBody] CreatePlantRequest req)
        {
            return await _plantService.CreatePlant(req, GetUserId());
        }
        [HttpPut("{plantId}")]
        public async Task<ActionResult> UpdatePlant(int plantId, [FromBody] UpdatePlantRequest req)
        {
            return await _plantService.UpdatePlant(plantId, req, GetUserId());
        }

        [HttpDelete("{plantId}")]
        public async Task<ActionResult> DeletePlant(int plantId)
        {
            return await _plantService.DeletePlant(plantId, GetUserId());
        }

        [HttpPut("{id}/care")]
        public async Task<ActionResult> UpdateCare(int id, [FromBody] UpdateCareRequest req)
        {
            return await _plantService.UpdateCare(id, req, GetUserId());
        }

        [HttpGet("status")]
        public async Task<ActionResult> GetStatus()
        {
            return await _plantService.GetPlantsStatus(GetUserId());
        }

        [HttpGet("{id}/history")]
        public async Task<ActionResult> GetPlantHistory(int id)
        {
            return await _plantService.GetPlantHistory(id, GetUserId());
        }

        [HttpPost("{id}/diary")]
        public async Task<ActionResult> AddDiaryEntry(int id, [FromBody] DiaryEntryRequest req)
        {
            return await _plantService.AddDiaryEntry(id, req, GetUserId());
        }
        [HttpGet("types")]
        public async Task<ActionResult> GetPlantTypes()
        {
            return await _plantService.GetPlantTypes();
        }

    }
}