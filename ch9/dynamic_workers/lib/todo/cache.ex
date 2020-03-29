defmodule Todo.Cache do
  use GenServer

  def start_link() do
    IO.puts("Starting cache server")
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one,
    )
  end

  def start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {Todo.Server, name})
  end

  def get_server(name) do
    case start_child(name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # Internal
  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, {}},
      type: :supervisor,
    }
  end
end
