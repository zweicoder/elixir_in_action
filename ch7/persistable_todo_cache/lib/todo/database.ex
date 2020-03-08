defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  # API
  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) when is_binary(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Internal
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end

  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  # Helpers
  def file_name(key) do
    Path.join(@db_folder, key)
  end
end