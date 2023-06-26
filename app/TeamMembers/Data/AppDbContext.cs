using Microsoft.EntityFrameworkCore;
using TeamMembers.Data.Models;

namespace TeamMembers.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(
        DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Person> People { get; set; }
}