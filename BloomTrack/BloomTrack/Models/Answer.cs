using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class Answer
    {
        [Key]
        public int Id_Answer { get; set; }
        public string Text_Answer { get; set; }
        [ForeignKey("Question")]
        public int Id_Question { get; set; }
        public Question Question { get; set; }
        public int Score { get; set; }
        [ForeignKey("PlantProblem")]
        public int? Id_Problem { get; set; }
        public PlantProblem? PlantProblem { get; set; }
    }
}
