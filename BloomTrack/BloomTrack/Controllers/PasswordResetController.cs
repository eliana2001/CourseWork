using BloomTrack.Interfaces;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;

namespace BloomTrack.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PasswordResetController : ControllerBase
    {
        private readonly IPasswordResetService _passwordResetService;

        public PasswordResetController(IPasswordResetService passwordResetService)
        {
            _passwordResetService = passwordResetService;
        }

        [HttpPost("request-code")]
        public async Task<ActionResult> RequestResetCode(RequestCodeRequest req)
        {
            return await _passwordResetService.RequestResetCode(req);
        }

        [HttpPost("verify-code")]
        public async Task<ActionResult> VerifyCode(VerifyCodeRequest req)
        {
            return await _passwordResetService.VerifyCode(req);
        }

        [HttpPost("reset-password")]
        public async Task<ActionResult> ResetPassword(ResetPasswordRequest req)
        {
            return await _passwordResetService.ResetPassword(req);
        }
    }
}