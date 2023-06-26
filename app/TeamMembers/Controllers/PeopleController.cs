using Microsoft.AspNetCore.Mvc;
using TeamMembers.Data;
using TeamMembers.Data.Models;

namespace TeamMembers.Controllers;

[ApiController]
[Route("[controller]")]
public class PeopleController : ControllerBase
{
    private readonly ILogger<PeopleController> _logger;
    private readonly AppDbContext _context;

    public PeopleController(ILogger<PeopleController> logger, AppDbContext context)
    {
        _logger = logger;
        _context = context;
    }

    [HttpGet]
    public IEnumerable<Person> Get()
    {
        return _context.People;
    }
}
