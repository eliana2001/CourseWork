using BloomTrack.Interfaces;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BloomTrack.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }
        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out int userId) ? userId : 0;
        }

        [HttpPost("login")]
        public async Task<ActionResult> Login([FromBody] LoginRequest req)
        {
            return await _authService.Login(req);
        }

        [HttpPost("register")]
        public async Task<ActionResult> Register(RegisterRequest req)
        {
            return await _authService.Register(req);
        }
        [HttpPut("profile")]
        public async Task<ActionResult> UpdateProfile([FromForm] UpdateProfileRequest req)
        {
            return await _authService.UpdateProfile(GetUserId(), req);
        }
        [HttpGet("me")]
        [Authorize]
        public async Task<ActionResult> GetMe()
        {
            return await _authService.GetUserInfo(GetUserId());
        }
    }
}
