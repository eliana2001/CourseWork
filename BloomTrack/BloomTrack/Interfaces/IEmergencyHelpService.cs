using BloomTrack.Requests;
using Microsoft.AspNetCore.Mvc;

namespace BloomTrack.Interfaces
{
    public interface IEmergencyHelpService
    {
        Task<ActionResult> GetProblems();
        Task<ActionResult> GetProblemDetails(int problemId);
        Task<ActionResult> SubmitDiagnosis(DiagnosisRequest req, int userId);
        Task<ActionResult> GetDiagnosisHistory(int userId); 

    }
}
