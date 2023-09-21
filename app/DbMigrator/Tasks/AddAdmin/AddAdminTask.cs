using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using TeamMembers.Data;

namespace DbMigrator.Tasks.AddAdmin;

public class AddAdminTask : ITask
{
    private readonly AddAdminConfiguration _config;
    private readonly ILogger<AddAdminTask> _logger;
    private readonly AppDbContext _dbContext;

    public AddAdminTask(
        ILogger<AddAdminTask> logger,
        IOptions<AddAdminConfiguration> config,
        AppDbContext dbContext)
    {
        this._config = config.Value;
        this._logger = logger;
        this._dbContext = dbContext;
    }
    
    public Task RunAsync(CancellationToken cancellationToken)
    {
        // Create User in Master.
        // Add to Database.
        
        // SQL:
        // CREATE USER [<identity-name>] FROM EXTERNAL PROVIDER;
        // ALTER ROLE db_datareader ADD MEMBER [<identity-name>];
        // ALTER ROLE db_datawriter ADD MEMBER [<identity-name>];
        // ALTER ROLE db_ddladmin ADD MEMBER [<identity-name>];
        throw new NotImplementedException();
    }
}