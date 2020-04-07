defmodule Todo.Database do
  @db_folder "./persist"
  @pool_size 3

  # API
  def start_link() do
    # IO.puts("Starting Todo.Database")
    # File.mkdir_p!(@db_folder)

    # children = Enum.map(1..@pool_size, &worker_spec/1)
    # Supervisor.start_link(children, strategy: :one_for_one)
  end

  def store(key, data) do
    :poolboy.transaction(__MODULE__,
    fn worker_pid -> Todo.DatabaseWorker.store(worker_pid, key, data) end)
  end

  def get(key) when is_binary(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid -> Todo.DatabaseWorker.get(worker_pid, key) end)
  end

  # Internal
  def child_spec(_) do
    File.mkdir_p!(@db_folder)
    :poolboy.child_spec(
      __MODULE__,
      [name: {:local, __MODULE__}, worker_module: Todo.DatabaseWorker, size: @pool_size],
      [@db_folder]
    )
  end
end
