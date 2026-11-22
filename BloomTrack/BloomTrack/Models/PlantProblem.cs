using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class PlantProblem
    {
        [Key]
        public int Id_Problem { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public string? InspectionGuide { get; set; } 
        public string? Solution { get; set; }
    }
}
