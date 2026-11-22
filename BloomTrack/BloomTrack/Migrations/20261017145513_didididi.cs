using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BloomTrack.Migrations
{
    /// <inheritdoc />
    public partial class didididi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Answers_PlantProblems_Id_Problem",
                table: "Answers");

            migrationBuilder.AlterColumn<int>(
                name: "Id_Problem",
                table: "Answers",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AddForeignKey(
                name: "FK_Answers_PlantProblems_Id_Problem",
                table: "Answers",
                column: "Id_Problem",
                principalTable: "PlantProblems",
                principalColumn: "Id_Problem");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Answers_PlantProblems_Id_Problem",
                table: "Answers");

            migrationBuilder.AlterColumn<int>(
                name: "Id_Problem",
                table: "Answers",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Answers_PlantProblems_Id_Problem",
                table: "Answers",
                column: "Id_Problem",
                principalTable: "PlantProblems",
                principalColumn: "Id_Problem",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
