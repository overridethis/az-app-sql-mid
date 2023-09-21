// See https://aka.ms/new-console-template for more information
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using DbMigrator.Tasks;
using DbMigrator.Data.Interceptors;
using DbMigrator.Tasks.Migrator;
using TeamMembers.Data;
using Microsoft.Extensions.Options;


IHost host = Host.CreateDefaultBuilder()
    .ConfigureServices((context, services) =>
    {
        services.AddLogging();
        services.Configure<MigratorConfiguration>(context.Configuration.GetSection("Migrator"));
        services.AddDbContext<AppDbContext>((provider, options) => 
        {   
            var connectionString = context.Configuration.GetConnectionString("DefaultConnection");
            var configuration = provider.GetService<IOptions<MigratorConfiguration>>()!;
            options.UseSqlServer(connectionString);
            options.AddInterceptors(new AzureAdAuthenticationDbConnectionInterceptor(configuration));
        });
        services.AddTransient<ITask, DbMigratorTask>();
    })
    .ConfigureLogging((context, logging) =>
    {
        logging.AddConsole();
    })
    .UseConsoleLifetime()
    .Build();

Console.WriteLine("[TASK RUNNER] Start");
var tasks = host.Services.GetServices<ITask>().ToList();
Console.WriteLine($"[TASK RUNNER] Executing {tasks.Count} tasks.");

foreach (var task in tasks)
    await task.RunAsync(CancellationToken.None);
Console.WriteLine("[TASK RUNNER] End");
