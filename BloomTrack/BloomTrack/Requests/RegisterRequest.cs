namespace BloomTrack.Requests
{
    public class RegisterRequest
    {
        public string FullName_User { get; set; }
        public string Login { get; set; }
        public string Password { get; set; }
        public string Email { get; set; }
        public string? AvatarUser { get; set; }
    }
}
