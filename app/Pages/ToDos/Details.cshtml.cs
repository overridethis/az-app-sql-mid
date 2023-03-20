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
    public class DetailsModel : PageModel
    {
        private readonly CoreTodo.Data.ToDoDbContext _context;

        public DetailsModel(CoreTodo.Data.ToDoDbContext context)
        {
            _context = context;
        }

      public ToDo ToDo { get; set; } = default!; 

        public async Task<IActionResult> OnGetAsync(int? id)
        {
            if (id == null || _context.ToDos == null)
            {
                return NotFound();
            }

            var todo = await _context.ToDos.FirstOrDefaultAsync(m => m.Id == id);
            if (todo == null)
            {
                return NotFound();
            }
            else 
            {
                ToDo = todo;
            }
            return Page();
        }
    }
}
