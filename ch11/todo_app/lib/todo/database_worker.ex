defmodule Todo.DatabaseWorker do
  use GenServer

  # API
  def start_link(folder) do
    GenServer.start_link(
      __MODULE__,
      folder
    )
  end

  def store(worker_id, key, data) do
    GenServer.cast(worker_id, {:store, key, data})
  end

  def get(worker_id, key) when is_binary(key) do
    GenServer.call(worker_id, {:get, key})
  end

  # Internal
  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, folder}
  end

  def handle_call({:get, key}, _, folder) do
    data =
      case File.read(file_name(folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, folder}
  end

  def handle_cast({:store, key, data}, state) do
    file_name(state, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  # Helpers
  def file_name(folder, key) do
    Path.join(folder, key)
  end
end
