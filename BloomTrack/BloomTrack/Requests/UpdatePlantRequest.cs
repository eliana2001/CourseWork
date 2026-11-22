namespace BloomTrack.Requests
{
    public class UpdatePlantRequest
    {
        public string Name_Plant { get; set; } = string.Empty;
        public int Id_TypePlant { get; set; }
        public DateOnly DatePurchase { get; set; }
        public string? PhotoPlant { get; set; }
    }
}
