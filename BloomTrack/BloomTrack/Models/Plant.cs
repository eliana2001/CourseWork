using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class Plant
    {
        [Key]
        public int Id_Plant { get; set; }
        public string Name_Plant { get; set; }
        [ForeignKey("User")]
        public int Id_User { get; set; }
        public User User { get; set; }
        [ForeignKey("TypePlant")]
        public int Id_TypePlant { get; set; }
        public TypePlant TypePlant { get; set; }
        public DateOnly DatePurchase { get; set; }
        public string? PhotoPlant { get; set; }
        public DateOnly? LastWateringDate { get; set; }    // дата последнего полива
        public DateOnly? LastFertilizingDate { get; set; } // дата после подкормки
        public DateTime? LastPhotoDate { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    }
}
