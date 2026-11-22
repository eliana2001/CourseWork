namespace BloomTrack.Requests
{
    public class CreatePlantRequest
    {
        public string? Name_Plant { get; set; }
        public int Id_TypePlant { get; set; }
        public DateOnly DatePurchase { get; set; }
        public string? PhotoPlant { get; set; }
    }
}
