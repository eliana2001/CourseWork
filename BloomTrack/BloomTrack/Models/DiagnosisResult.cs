using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class DiagnosisResult
    {
        [Key]
        public int Id_Result { get; set; }
        public string Description { get; set; }
        [ForeignKey("PlantProblem")]
        public int Id_Problem { get; set; }
        public PlantProblem PlantProblem { get; set; }
        [ForeignKey("User")]
        public int Id_User { get; set; }
        public User User { get; set; }
        [ForeignKey("Plant")]
        public int Id_Plant { get; set; }
        public Plant Plant { get; set; }
        public DateTime Date_Diagnostic { get; set; }
    }
}
