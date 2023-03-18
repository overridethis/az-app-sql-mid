namespace CoreTodo.Data.Models;

public class ToDoComment
{
    public int Id { get; set; }
    public ToDo ToDo { get; set; }
    public string Comment { get; set; }
}
