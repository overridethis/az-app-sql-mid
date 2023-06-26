using TeamMembers.Data.Models;
using TeamMembers.Services;

namespace TeamMembers.Data;

internal class DbInitializer
{
    internal static void Initialize(AppDbContext dbContext, IFakeDataService fakes)
    {
        ArgumentNullException.ThrowIfNull(dbContext, nameof(dbContext));
        dbContext.Database.EnsureCreated();

        if (dbContext.People.Any()) return;

        // add 50 comments.
        var people = fakes.GetPeopleAsync(50).Result;
        dbContext.People.AddRange(people);
        dbContext.SaveChanges();
    }
}

public static class DbInitializerExtensions
{
    public static IApplicationBuilder SeedDb(this IApplicationBuilder app)
    {
        using var scope = app.ApplicationServices.CreateScope();
        var services = scope.ServiceProvider;
        var context = services.GetRequiredService<AppDbContext>();
        var fakes = services.GetRequiredService<IFakeDataService>();
        DbInitializer.Initialize(context, fakes);
        return app;
    }   
}