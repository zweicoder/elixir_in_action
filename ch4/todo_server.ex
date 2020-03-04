defmodule TodoServer do
  def start() do
    spawn(fn -> loop(TodoList.new()) end)
  end

  def add_entry(server, entry) do
    send(server, {:add_entry, entry})
  end

  def entries(server) do
    send(server, {:entries})
    receive do
      response -> response
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_state = receive do
      message -> process_message(todo_list, message)
    end
    loop(new_state)
  end

  defp process_message(todo_list, {:add_entry, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:entries}) do
    TodoList.entries(todo_list)
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, fn entry, todo_list -> add_entry(todo_list, entry) end)
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_id, entry} -> entry.date == date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, id, update_fn) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_id = old_entry.id
        new_entry = %{id: ^old_id} = update_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, id)}
  end
end
