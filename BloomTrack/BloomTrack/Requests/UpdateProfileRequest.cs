namespace BloomTrack.Requests
{
    public class UpdateProfileRequest
    {
        public string? FullName_User { get; set; }
        public string? Email { get; set; }
        public IFormFile? Avatar { get; set; }
    }
}
