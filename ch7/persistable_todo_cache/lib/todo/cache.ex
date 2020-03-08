defmodule Todo.Cache do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def get_server(pid, name) do
    GenServer.call(pid, {:get_server, name})
  end

  # Internal
  @impl GenServer
  def init(_) do
    # hack
    Todo.Database.start()

    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get_server, name}, _, state) do
    case Map.fetch(state, name) do
      {:ok, server} ->
        {:reply, server, state}

      :error ->
        {:ok, server} = Todo.Server.start(name)
        new_state = Map.put(state, name, server)
        {:reply, server, new_state}
    end
  end
end
