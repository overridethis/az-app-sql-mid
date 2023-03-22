using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using CoreTodo.Data;
using CoreTodo.Data.Models;
using Microsoft.AspNetCore.Authorization;

namespace CoreTodo.Pages.ToDos
{
    [Authorize]
    public class CreateModel : PageModel
    {
        private readonly CoreTodo.Data.ToDoDbContext _context;

        public CreateModel(CoreTodo.Data.ToDoDbContext context)
        {
            _context = context;
        }

        public IActionResult OnGet()
        {
            return Page();
        }

        [BindProperty]
        public ToDo ToDo { get; set; } = default!;
        

        // To protect from overposting attacks, see https://aka.ms/RazorPagesCRUD
        public async Task<IActionResult> OnPostAsync()
        {
          if (!ModelState.IsValid || _context.ToDos == null || ToDo == null)
            {
                return Page();
            }

            _context.ToDos.Add(ToDo);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
