using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BloomTrack.Migrations
{
    /// <inheritdoc />
    public partial class avavava : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AvatarUser",
                table: "Users",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AvatarUser",
                table: "Users");
        }
    }
}
