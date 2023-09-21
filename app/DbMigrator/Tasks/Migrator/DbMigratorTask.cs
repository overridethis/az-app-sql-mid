using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using TeamMembers.Data;

namespace DbMigrator.Tasks.Migrator;

public class DbMigratorTask : ITask
{
    private readonly ILogger<DbMigratorTask> _logger;
    private readonly MigratorConfiguration _config;
    private readonly AppDbContext _dbContext;

    public DbMigratorTask(
        ILogger<DbMigratorTask> logger,
        IOptions<MigratorConfiguration> config,
        AppDbContext dbContext)
    {
        this._config = config.Value;
        this._logger = logger;
        this._dbContext = dbContext;
    }

    public async Task RunAsync(CancellationToken cancellationToken)
    {
        this._logger.LogInformation("[DbMigrationTask] started");
        this._logger.LogInformation("[DbMigrationTask:Configuration] {config}", this._config);

        if (this._config.RunMigration) {
            await this._dbContext.Database.MigrateAsync(cancellationToken);
        }

        this._logger.LogInformation("[DbMigrationTask] completed");
    }
}