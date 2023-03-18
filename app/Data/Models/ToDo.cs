namespace CoreTodo.Data.Models;

public class ToDo
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public bool IsComplete { get; set; }
    public IList<ToDoComment> Comments { get; set; } = new List<ToDoComment>();
}