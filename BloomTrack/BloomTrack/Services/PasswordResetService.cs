using BloomTrack.Connection;
using BloomTrack.Interfaces;
using BloomTrack.Models;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BloomTrack.Services
{
    public class PasswordResetService : IPasswordResetService
    {
        private readonly ContextDb _context;
        private readonly EmailService _emailService;

        public PasswordResetService(ContextDb context, EmailService emailService)
        {
            _context = context;
            _emailService = emailService;
        }

        public async Task<ActionResult> RequestResetCode(RequestCodeRequest req)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == req.Email);

            if (user == null)
                return new BadRequestObjectResult(new { message = "Пользователь с таким email не найден" });

            var code = GenerateRandomCode();

            var resetCode = new PasswordResetCode
            {
                Email = req.Email,
                Code = code,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddMinutes(10),
                IsUsed = false
            };

            _context.PasswordResetCodes.Add(resetCode);
            await _context.SaveChangesAsync();
            await _emailService.SendPasswordResetCodeAsync(req.Email, code);

            return new OkObjectResult(new
            {
                message = "Код сгенерирован",
                code = code,
                email = req.Email
            });
        }

        public async Task<ActionResult> VerifyCode(VerifyCodeRequest req)
        {
            var resetCode = await _context.PasswordResetCodes
                .Where(c => c.Email == req.Email && c.Code == req.Code)
                .OrderByDescending(c => c.CreatedAt)
                .FirstOrDefaultAsync();

            if (resetCode == null)
                return new BadRequestObjectResult(new { message = "Неверный код" });

            if (resetCode.IsUsed)
                return new BadRequestObjectResult(new { message = "Код уже использован" });

            if (resetCode.ExpiresAt < DateTime.UtcNow)
                return new BadRequestObjectResult(new { message = "Код истёк" });

            return new OkObjectResult(new { message = "Код подтверждён", isValid = true });
        }

        public async Task<ActionResult> ResetPassword(ResetPasswordRequest req)
        {
            if (string.IsNullOrEmpty(req.NewPassword) || req.NewPassword.Length < 6)
                return new BadRequestObjectResult("Пароль должен содержать не менее 6 символов");
            var resetCode = await _context.PasswordResetCodes
                .Where(c => c.Email == req.Email && c.Code == req.Code)
                .OrderByDescending(c => c.CreatedAt)
                .FirstOrDefaultAsync();

            if (resetCode == null || resetCode.IsUsed || resetCode.ExpiresAt < DateTime.UtcNow)
                return new BadRequestObjectResult(new { message = "Недействительный код" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == req.Email);

            if (user == null)
                return new NotFoundObjectResult(new { message = "Пользователь не найден" });

            user.Password = req.NewPassword;
            await _context.SaveChangesAsync();

            resetCode.IsUsed = true;
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { message = "Пароль успешно изменён" });
        }

        private string GenerateRandomCode()
        {
            var random = new Random();
            return random.Next(100000, 999999).ToString();
        }
    }
}