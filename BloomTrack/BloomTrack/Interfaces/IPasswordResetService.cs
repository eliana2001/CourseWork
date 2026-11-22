using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;

namespace BloomTrack.Interfaces
{
    public interface IPasswordResetService
    {
        Task<ActionResult> RequestResetCode(RequestCodeRequest req);
        Task<ActionResult> VerifyCode(VerifyCodeRequest req);
        Task<ActionResult> ResetPassword(ResetPasswordRequest req);
    }
}