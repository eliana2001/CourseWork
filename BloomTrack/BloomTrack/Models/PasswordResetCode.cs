using System.ComponentModel.DataAnnotations;

namespace BloomTrack.Models
{
    public class PasswordResetCode
    {
        [Key]
        public int Id_Code { get; set; }

        [Required]
        public string Email { get; set; }
        public string Code { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsUsed { get; set; }
    }
}
