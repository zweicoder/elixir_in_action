defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @pool_size 3

  # API
  def start_link(_) do
    IO.puts("Starting Todo.Database")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
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
  @impl GenServer
  def init(_) do
    workers = start_workers()
    {:ok, workers}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _ , workers) do
    worker = key
    |> :erlang.phash2(@pool_size)
    |> (&Map.get(workers, &1)).()

    {:reply, worker, workers}
  end

  # Helpers
  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  defp start_workers() do
    for idx <- 1..@pool_size, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      IO.puts("Started workers: #{inspect(pid)}")
      {idx-1, pid}
    end
  end
end
