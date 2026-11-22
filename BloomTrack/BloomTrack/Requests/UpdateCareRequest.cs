namespace BloomTrack.Requests
{
    public class UpdateCareRequest
    {
        public DateOnly? LastWateringDate { get; set; }
        public DateOnly? LastFertilizingDate { get; set; }
        public string? Notes { get; set; }
    }
}
