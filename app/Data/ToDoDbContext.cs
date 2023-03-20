using Microsoft.EntityFrameworkCore;
using CoreTodo.Data.Models;

namespace CoreTodo.Data;

public class ToDoDbContext : DbContext
{   protected readonly IConfiguration Configuration;
    protected readonly ILogger<ToDoDbContext> Logger;

    public ToDoDbContext(
        IConfiguration configuration,
        ILogger<ToDoDbContext> logger)
    {
        Configuration = configuration;
        Logger = logger;
    }

    public DbSet<ToDo> ToDos { get; set; }

    public DbSet<ToDoComment> ToDoComments { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        var connectionString = Configuration.GetConnectionString("DefaultConnection");
        Logger.LogInformation($"Connection Strings: {connectionString}.");
        options.UseSqlServer(connectionString);
    } 
}