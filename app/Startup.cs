namespace CoreTodo;

using Microsoft.EntityFrameworkCore;
using CoreTodo.Data;

public static class StartupExtensions
{
    /// <summary>
    /// Migrates the database to the latest version when configured to do so.
    /// </summary>
    /// <param name="builder">Application Builder</param>
    /// <param name="app">Web App</param>
    public static async Task MigrateDb(this WebApplicationBuilder builder, WebApplication app)
    {
        var startupMigration = builder.Configuration.GetValue<bool>("Db:RunMigrations");
        if (startupMigration)
        {
            await using var scope = app.Services.CreateAsyncScope();
            using var db = scope.ServiceProvider.GetService<ToDoDbContext>();
            if (db is object)
            {
                await db.Database.MigrateAsync();
            }
        }
    }
}