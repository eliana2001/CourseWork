using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BloomTrack.Models
{
    public class AnswerHistory
    {
        [Key]
        public int Id_AnswerHistory { get; set; }
        [ForeignKey("DiagnosisResult")]
        public int Id_Result { get; set; }
        public DiagnosisResult DiagnosisResult { get; set; }
        [ForeignKey("User")]
        public int Id_User {  get; set; }
        public User User { get; set; }
        [ForeignKey("Answer")]
        public int Id_Answer {  get; set; }
        public Answer Answer { get; set; }
    }
}
