using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using CoreTodo.Data;
using CoreTodo.Data.Models;

namespace CoreTodo.Pages.ToDos
{
    public class IndexModel : PageModel
    {
        private readonly CoreTodo.Data.ToDoDbContext _context;

        public IndexModel(CoreTodo.Data.ToDoDbContext context)
        {
            _context = context;
        }

        public IList<ToDo> ToDo { get;set; } = default!;

        public async Task OnGetAsync()
        {
            if (_context.ToDos != null)
            {
                ToDo = await _context.ToDos.ToListAsync();
            }
        }
    }
}
