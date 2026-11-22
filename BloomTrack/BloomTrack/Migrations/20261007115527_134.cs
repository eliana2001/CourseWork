using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BloomTrack.Migrations
{
    /// <inheritdoc />
    public partial class _134 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Plants",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "LastPhotoDate",
                table: "Plants",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Plants");

            migrationBuilder.DropColumn(
                name: "LastPhotoDate",
                table: "Plants");
        }
    }
}
