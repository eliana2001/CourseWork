using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class InspectionStage
    {
        [Key]
        public int Id_Stage { get; set; }
        public string Text_Stage { get; set; }
        [ForeignKey("PlantProblem")]
        public int Id_Problem {  get; set; }
        public PlantProblem PlantProblem { get; set; }

    }
}
