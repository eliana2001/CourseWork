using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace BloomTrack.Migrations
{
    /// <inheritdoc />
    public partial class idididi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PlantProblems",
                columns: table => new
                {
                    Id_Problem = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    InspectionGuide = table.Column<string>(type: "text", nullable: true),
                    Solution = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlantProblems", x => x.Id_Problem);
                });

            migrationBuilder.CreateTable(
                name: "DiagnosisResults",
                columns: table => new
                {
                    Id_Result = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Id_Problem = table.Column<int>(type: "integer", nullable: false),
                    Id_User = table.Column<int>(type: "integer", nullable: false),
                    Id_Plant = table.Column<int>(type: "integer", nullable: false),
                    Date_Diagnostic = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DiagnosisResults", x => x.Id_Result);
                    table.ForeignKey(
                        name: "FK_DiagnosisResults_PlantProblems_Id_Problem",
                        column: x => x.Id_Problem,
                        principalTable: "PlantProblems",
                        principalColumn: "Id_Problem",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DiagnosisResults_Plants_Id_Plant",
                        column: x => x.Id_Plant,
                        principalTable: "Plants",
                        principalColumn: "Id_Plant",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DiagnosisResults_Users_Id_User",
                        column: x => x.Id_User,
                        principalTable: "Users",
                        principalColumn: "Id_User",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "InspectionStages",
                columns: table => new
                {
                    Id_Stage = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Text_Stage = table.Column<string>(type: "text", nullable: false),
                    Id_Problem = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InspectionStages", x => x.Id_Stage);
                    table.ForeignKey(
                        name: "FK_InspectionStages_PlantProblems_Id_Problem",
                        column: x => x.Id_Problem,
                        principalTable: "PlantProblems",
                        principalColumn: "Id_Problem",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Questions",
                columns: table => new
                {
                    Id_Question = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Text_Question = table.Column<string>(type: "text", nullable: false),
                    Id_Problem = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Questions", x => x.Id_Question);
                    table.ForeignKey(
                        name: "FK_Questions_PlantProblems_Id_Problem",
                        column: x => x.Id_Problem,
                        principalTable: "PlantProblems",
                        principalColumn: "Id_Problem",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Answers",
                columns: table => new
                {
                    Id_Answer = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Text_Answer = table.Column<string>(type: "text", nullable: false),
                    Id_Question = table.Column<int>(type: "integer", nullable: false),
                    Score = table.Column<int>(type: "integer", nullable: false),
                    Id_Problem = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Answers", x => x.Id_Answer);
                    table.ForeignKey(
                        name: "FK_Answers_PlantProblems_Id_Problem",
                        column: x => x.Id_Problem,
                        principalTable: "PlantProblems",
                        principalColumn: "Id_Problem",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Answers_Questions_Id_Question",
                        column: x => x.Id_Question,
                        principalTable: "Questions",
                        principalColumn: "Id_Question",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AnswerHistories",
                columns: table => new
                {
                    Id_AnswerHistory = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Id_Result = table.Column<int>(type: "integer", nullable: false),
                    Id_User = table.Column<int>(type: "integer", nullable: false),
                    Id_Answer = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AnswerHistories", x => x.Id_AnswerHistory);
                    table.ForeignKey(
                        name: "FK_AnswerHistories_Answers_Id_Answer",
                        column: x => x.Id_Answer,
                        principalTable: "Answers",
                        principalColumn: "Id_Answer",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AnswerHistories_DiagnosisResults_Id_Result",
                        column: x => x.Id_Result,
                        principalTable: "DiagnosisResults",
                        principalColumn: "Id_Result",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AnswerHistories_Users_Id_User",
                        column: x => x.Id_User,
                        principalTable: "Users",
                        principalColumn: "Id_User",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AnswerHistories_Id_Answer",
                table: "AnswerHistories",
                column: "Id_Answer");

            migrationBuilder.CreateIndex(
                name: "IX_AnswerHistories_Id_Result",
                table: "AnswerHistories",
                column: "Id_Result");

            migrationBuilder.CreateIndex(
                name: "IX_AnswerHistories_Id_User",
                table: "AnswerHistories",
                column: "Id_User");

            migrationBuilder.CreateIndex(
                name: "IX_Answers_Id_Problem",
                table: "Answers",
                column: "Id_Problem");

            migrationBuilder.CreateIndex(
                name: "IX_Answers_Id_Question",
                table: "Answers",
                column: "Id_Question");

            migrationBuilder.CreateIndex(
                name: "IX_DiagnosisResults_Id_Plant",
                table: "DiagnosisResults",
                column: "Id_Plant");

            migrationBuilder.CreateIndex(
                name: "IX_DiagnosisResults_Id_Problem",
                table: "DiagnosisResults",
                column: "Id_Problem");

            migrationBuilder.CreateIndex(
                name: "IX_DiagnosisResults_Id_User",
                table: "DiagnosisResults",
                column: "Id_User");

            migrationBuilder.CreateIndex(
                name: "IX_InspectionStages_Id_Problem",
                table: "InspectionStages",
                column: "Id_Problem");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_Id_Problem",
                table: "Questions",
                column: "Id_Problem");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AnswerHistories");

            migrationBuilder.DropTable(
                name: "InspectionStages");

            migrationBuilder.DropTable(
                name: "Answers");

            migrationBuilder.DropTable(
                name: "DiagnosisResults");

            migrationBuilder.DropTable(
                name: "Questions");

            migrationBuilder.DropTable(
                name: "PlantProblems");
        }
    }
}
