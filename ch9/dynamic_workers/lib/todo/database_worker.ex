defmodule Todo.DatabaseWorker do
  use GenServer

  # API
  def start_link({folder, worker_id}) do
    IO.puts("Starting db_worker #{worker_id}")

    GenServer.start_link(
      __MODULE__,
      folder,
      name: via_tuple(worker_id)
    )
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) when is_binary(key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
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

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
