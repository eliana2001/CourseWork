using BloomTrack.Interfaces;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BloomTrack.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EmergencyHelpController : ControllerBase
    {
        private readonly IEmergencyHelpService _emergencyHelpService;

        public EmergencyHelpController(IEmergencyHelpService emergencyHelpService)
        {
            _emergencyHelpService = emergencyHelpService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out int userId) ? userId : 0;
        }

        [HttpGet("problems")]
        public async Task<ActionResult> GetProblems()
        {
            return await _emergencyHelpService.GetProblems();
        }

        [HttpGet("problems/{id}")]
        public async Task<ActionResult> GetProblemDetails(int id)
        {
            return await _emergencyHelpService.GetProblemDetails(id);
        }

        [HttpPost("diagnose")]
        public async Task<ActionResult> SubmitDiagnosis([FromBody] DiagnosisRequest req)
        {
            return await _emergencyHelpService.SubmitDiagnosis(req, GetUserId());
        }

        [HttpGet("history")]
        public async Task<ActionResult> GetDiagnosisHistory()
        {
            return await _emergencyHelpService.GetDiagnosisHistory(GetUserId());
        }
    }
}