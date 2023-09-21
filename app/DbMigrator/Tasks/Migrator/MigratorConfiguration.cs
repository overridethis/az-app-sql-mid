namespace DbMigrator.Tasks.Migrator;

public record MigratorConfiguration
{
    public RunMode Mode { get; init; }
    public bool RunMigration { get; init; } = false;
}