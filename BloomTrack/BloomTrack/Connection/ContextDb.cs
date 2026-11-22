using BloomTrack.Models;
using Microsoft.EntityFrameworkCore;

namespace BloomTrack.Connection
{
    public class ContextDb : DbContext
    {
        public ContextDb(DbContextOptions<ContextDb> options) : base(options) { }
        public DbSet<Plant> Plants { get; set; }
        public DbSet<TypeCare> TypeCares { get; set; }
        public DbSet<TypePlant> TypePlants { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<CareHistory> CareHistories { get; set; }
        public DbSet<PlantProblem> PlantProblems { get; set; }
        public DbSet<InspectionStage> InspectionStages { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<Answer> Answers { get; set; }
        public DbSet<DiagnosisResult> DiagnosisResults { get; set; }
        public DbSet<AnswerHistory> AnswerHistories { get; set; }
        public DbSet<PasswordResetCode> PasswordResetCodes { get; set; }
    }
}
