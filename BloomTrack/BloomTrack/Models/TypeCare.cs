using System.ComponentModel.DataAnnotations;

namespace BloomTrack.Models
{
    public class TypeCare
    {
        [Key]
        public int Id_TypeCare { get; set; }
        public string Name_TypeCare { get; set; }
    }
}
