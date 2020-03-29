defmodule EchoServer do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(id))
  end

  def call(id, request) do
    GenServer.call(via_tuple(id), request)
  end

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call(request, _, state) do
    {:reply, "[echo] #{inspect(request)}", state}
  end

  defp via_tuple(id) do
    {:via, Registry, {:some_registry, {__MODULE__, id}}}
  end
end
