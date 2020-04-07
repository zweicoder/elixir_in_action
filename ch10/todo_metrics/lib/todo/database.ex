defmodule Todo.Database do
  @db_folder "./persist"
  @pool_size 3

  # API
  def start_link() do
    IO.puts("Starting Todo.Database")
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def store(key, data) do
    choose_worker(key)
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) when is_binary(key) do
    choose_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  # Internal
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # Helpers
  defp worker_spec(id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, id}}
    Supervisor.child_spec(default_worker_spec, id: id)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
