using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class Question
    {
        [Key]
        public int Id_Question { get; set; }
        public string Text_Question { get; set; }
        [ForeignKey("PlantProblem")]
        public int Id_Problem { get; set; }
        public PlantProblem PlantProblem { get; set; }
    }
}
