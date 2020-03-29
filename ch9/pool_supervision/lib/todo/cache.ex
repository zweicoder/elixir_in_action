defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    IO.puts("Starting cache server")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_server(name) do
    GenServer.call(__MODULE__, {:get_server, name})
  end

  # Internal
  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get_server, name}, _, state) do
    case Map.fetch(state, name) do
      {:ok, server} ->
        {:reply, server, state}

      :error ->
        {:ok, server} = Todo.Server.start_link(name)
        new_state = Map.put(state, name, server)
        {:reply, server, new_state}
    end
  end
end
