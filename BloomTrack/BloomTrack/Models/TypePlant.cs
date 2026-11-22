using System.ComponentModel.DataAnnotations;

namespace BloomTrack.Models
{
    public class TypePlant
    {
        [Key]
        public int Id_TypePlant { get; set; }
        public string Name_TypePlant { get; set; }
        //интервалы поливания для автом расчета
        public int WateringIntervalDays { get; set; }      // полив
        public int FertilizingIntervalDays { get; set; } //подкормка

    }
}
