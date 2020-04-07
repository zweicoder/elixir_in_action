defmodule Todo.Server do
  use Agent, restart: :temporary

  # API
  def start_link(name) do
    IO.puts("Starting new Todo.Server")
    Agent.start_link(fn ->
      IO.puts("Starting Todo.Server for #{name}")
      {name, Todo.Database.get(name) || Todo.List.new()}
    end,
    name: via_tuple(name))
  end

  def add_entry(pid, entry) do
    Agent.cast(pid, fn {name, todo_list} ->
      new_todo_list = Todo.List.add_entry(todo_list, entry)
      Todo.Database.store(name, new_todo_list)
      {name, new_list}
    end)
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
    Agent.get(pid, fn {_name, todo_list} ->
      Todo.List.entries(todo_list, date)
    end)
  end


  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
