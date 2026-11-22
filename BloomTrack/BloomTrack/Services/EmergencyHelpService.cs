using BloomTrack.Connection;
using BloomTrack.Interfaces;
using BloomTrack.Models;
using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BloomTrack.Services
{
    public class EmergencyHelpService : IEmergencyHelpService
    {
        private readonly ContextDb _context;

        public EmergencyHelpService(ContextDb context)
        {
            _context = context;
        }
        public async Task<ActionResult> GetProblems()
        {
            var problems = await _context.PlantProblems
                .Select(p => new { p.Id_Problem, p.Name })
                .ToListAsync();

            return new OkObjectResult(problems);
        }

        public async Task<ActionResult> GetProblemDetails(int problemId)
        {
            var problem = await _context.PlantProblems
                .FirstOrDefaultAsync(p => p.Id_Problem == problemId);

            if (problem == null)
                return new NotFoundObjectResult("Проблема не найдена");
            var stages = await _context.InspectionStages
                .Where(s => s.Id_Problem == problemId)
                .Select(s => new { s.Id_Stage, s.Text_Stage })
                .ToListAsync();

            var questions = await _context.Questions
                .Where(q => q.Id_Problem == problemId)
                .Select(q => new { q.Id_Question, q.Text_Question })
                .ToListAsync();
            var questionsWithAnswers = new List<object>();
            foreach (var question in questions)
            {
                var answers = await _context.Answers
                    .Where(a => a.Id_Question == question.Id_Question)
                    .Select(a => new
                    {
                        a.Id_Answer,
                        a.Text_Answer,
                        a.Score,
                        a.Id_Problem
                    })
                    .ToListAsync();

                questionsWithAnswers.Add(new
                {
                    question.Id_Question,
                    question.Text_Question,
                    Answers = answers
                });
            }

            var result = new
            {
                problem.Id_Problem,
                problem.Name,
                problem.Description,
                problem.InspectionGuide,
                problem.Solution,
                InspectionStages = stages,
                Questions = questionsWithAnswers
            };

            return new OkObjectResult(result);
        }
        public async Task<ActionResult> SubmitDiagnosis(DiagnosisRequest req, int userId)
        {
            var plantExists = await _context.Plants
                .AnyAsync(p => p.Id_Plant == req.Id_Plant && p.Id_User == userId);

            if (!plantExists)
                return new NotFoundObjectResult("Растение не найдено");

            var diagnosis = new DiagnosisResult
            {
                Id_User = userId,
                Id_Plant = req.Id_Plant,
                Id_Problem = req.Id_Problem,
                Date_Diagnostic = DateTime.UtcNow
            };

            _context.DiagnosisResults.Add(diagnosis);
            await _context.SaveChangesAsync();

            var problem = await _context.PlantProblems
                .FirstOrDefaultAsync(p => p.Id_Problem == req.Id_Problem);

            return new OkObjectResult(new
            {
                message = "Диагностика успешно сохранена",
                solution = problem?.Solution
            });
        }
        public async Task<ActionResult> GetDiagnosisHistory(int userId)
        {
            var history = await _context.DiagnosisResults
                .Where(d => d.Id_User == userId)
                .OrderByDescending(d => d.Date_Diagnostic)
                .Select(d => new
                {
                    d.Id_Result,
                    d.Date_Diagnostic,
                    ProblemName = _context.PlantProblems.Where(p => p.Id_Problem == d.Id_Problem).Select(p => p.Name).FirstOrDefault() ?? "Неизвестно",

                    Solution = _context.PlantProblems.Where(p => p.Id_Problem == d.Id_Problem).Select(p => p.Solution).FirstOrDefault() ?? "Нет рекомендаций",

                    PlantName = _context.Plants.Where(p => p.Id_Plant == d.Id_Plant).Select(p => p.Name_Plant).FirstOrDefault() ?? "Растение удалено"
                })
                .ToListAsync();

            return new OkObjectResult(history);
        }
    }
}