using Microsoft.EntityFrameworkCore;
using CoreTodo.Data.Models;

namespace CoreTodo.Data;

public class ToDoDbContext : DbContext
{   protected readonly IConfiguration Configuration;

    public ToDoDbContext(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public DbSet<ToDo> ToDos { get; set; }

    public DbSet<ToDoComment> ToDoComments { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        var connectionString = Configuration.GetConnectionString("DefaultConnection");
        options.UseSqlServer(connectionString);
    } 
}