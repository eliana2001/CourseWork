using BloomTrack.Connection;
using BloomTrack.Interfaces;
using BloomTrack.Models;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BloomTrack.Services
{
    public class AuthService : IAuthService
    {
        private readonly ContextDb _context;
        private readonly JwtService _jwtService;

        public AuthService(ContextDb context, JwtService jwtService)
        {
            _context = context;
            _jwtService = jwtService;
        }

        public async Task<ActionResult> Register(RegisterRequest req)
        {
            if (await _context.Users.AnyAsync(u => u.Login == req.Login))
                return new BadRequestObjectResult("Логин уже занят");
            if (await _context.Users.AnyAsync(u => u.Email == req.Email))
                return new BadRequestObjectResult("Email уже зарегистрирован");

            var user = new User
            {
                FullName_User = req.FullName_User,
                Login = req.Login,
                Password = req.Password,
                Email = req.Email,
                AvatarUser = req.AvatarUser
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            var token = _jwtService.CreateToken(user);

            return new OkObjectResult(new
            {
                message = "Регистрация успешна",
                token,
                user = new
                {
                    user.Id_User,
                    user.FullName_User,
                    user.Login,
                    user.Email,
                    user.AvatarUser
                }
            });
        }

        public async Task<ActionResult> Login(LoginRequest req)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Login == req.Login);
            if (user == null || req.Password != user.Password)
                return new BadRequestObjectResult("Неверный логин или пароль");

            var token = _jwtService.CreateToken(user);
            return new OkObjectResult(new
            {
                message = "Вход выполнен успешно",
                token,
                user = new
                {
                    user.Id_User,
                    user.FullName_User,
                    user.Login,
                    user.Email
                }
            });
        }
        public async Task<ActionResult> GetUserInfo(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return new NotFoundObjectResult("Пользователь не найден");

            return new OkObjectResult(new
            {
                user.Id_User,
                user.FullName_User,
                user.Login,
                user.Email,
                user.AvatarUser
            });
        }
        public async Task<ActionResult> UpdateProfile(int userId, UpdateProfileRequest req)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return new NotFoundObjectResult("Пользователь не найден");
            if (req.Email != null && req.Email != user.Email)
            {
                if (await _context.Users.AnyAsync(u => u.Email == req.Email && u.Id_User != userId))
                    return new BadRequestObjectResult("Email уже используется");
            }

            if (req.FullName_User != null)
                user.FullName_User = req.FullName_User;

            if (req.Email != null)
                user.Email = req.Email;
            if (req.Avatar != null && req.Avatar.Length > 0)
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "avatars");
                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                if (user.AvatarUser != null)
                {
                    var oldFilePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", user.AvatarUser);
                    if (File.Exists(oldFilePath))
                        File.Delete(oldFilePath);
                }

                var fileName = $"{userId}_{Guid.NewGuid()}{Path.GetExtension(req.Avatar.FileName)}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await req.Avatar.CopyToAsync(stream);
                }

                user.AvatarUser = $"/avatars/{fileName}";
            }

            await _context.SaveChangesAsync();

            return new OkObjectResult(new
            {
                user.Id_User,
                user.FullName_User,
                user.Login,
                user.Email,
                user.AvatarUser
            });
        }
    }
}