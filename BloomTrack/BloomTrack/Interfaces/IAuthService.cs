using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;

namespace BloomTrack.Interfaces
{
    public interface IAuthService 
    {
        Task<ActionResult> Register(RegisterRequest req);
        Task<ActionResult> Login(LoginRequest req);
        Task<ActionResult> UpdateProfile(int userId, UpdateProfileRequest req);
        Task<ActionResult> GetUserInfo(int userId);
    }
}
