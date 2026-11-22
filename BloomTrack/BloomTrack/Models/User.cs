using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;

namespace BloomTrack.Models
{
    public class User
    {
        [Key]
        public int Id_User { get; set; }
        public string FullName_User { get; set; }
        public string Login { get; set; }
        public string Password { get; set; }
        public string Email { get; set; }
        public string? AvatarUser { get; set; }
        //монстера
        //
    }
}
