namespace DbMigrator.Tasks;

public interface ITask
{
    Task RunAsync(CancellationToken cancellationToken);
}
