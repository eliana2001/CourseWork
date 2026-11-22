using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class CareHistory
    {
        [Key]
        public int Id_CareHistory { get; set; }

        [ForeignKey("Plant")]
        public int Id_Plant { get; set; }
        public virtual Plant? Plant { get; set; }

        [ForeignKey("TypeCare")]
        public int Id_TypeCare { get; set; }
        public virtual TypeCare? TypeCare { get; set; }

        public DateOnly CareDate { get; set; }
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
