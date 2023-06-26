using Microsoft.EntityFrameworkCore;
using TeamMembers.Data;
using TeamMembers.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Configuration.AddJsonFile("appsettings.Local.json",
        optional: true,
        reloadOnChange: true);
builder.Services.AddControllersWithViews();
builder.Services.AddDbContext<AppDbContext>(options =>
{   
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.UseLoggerFactory(LoggerFactory.Create(builder => builder.AddConsole()));
});
builder.Services.AddScoped<DbInitializer>();
builder.Services.Configure<MockarooOptions>(builder.Configuration.GetSection("Mockaroo"));
builder.Services.AddScoped<IFakeDataService, FakeDataService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.SeedDb();
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();


app.MapControllerRoute(
    name: "default",
    pattern: "{controller}/{action=Index}/{id?}");

app.MapFallbackToFile("index.html");

app.Run();
