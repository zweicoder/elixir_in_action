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

defmodule TodoList.CsvImporter do
  def import(filename) do
    File.stream!(filename)
    |> Stream.map(fn line -> String.trim(line) |> String.split(",") end)
    |> Stream.map(fn [date, title] -> [String.split(date, "/"), title] end)
    |> Stream.map(fn [date, title] -> parse_entry(date, title) end)
    |> TodoList.new()
  end

  def parse_entry(date, title) do
    [year, month, day] = date
    %{date: Date.from_iso8601!("#{year}-#{month}-#{day}"), title: title}
  end
end
