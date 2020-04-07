defmodule SimpleRegistry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(key) do
    GenServer.call(__MODULE__, {:register, key, self()})
  end
  def whereis(key) do
    GenServer.call(__MODULE__, {:whereis, key})
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.link(pid)
        {:reply, :ok, Map.put(process_registry, key, pid)}
      _ ->
        {:reply, :error, process_registry}
    end
  end

  @impl GenServer
  def handle_call({:whereis, key}, _, process_registry) do
    {:reply, Map.get(process_registry, key), process_registry}
  end

  @impl true
  def handle_info({:EXIT, pid, reason}, process_registry) do
    IO.puts("Handling :EXIT due to #{reason}")
    {:noreply, deregister_pid(process_registry, pid)}
  end

  defp deregister_pid(process_registry, pid) do
    process_registry
    |> Enum.reject(fn {_key, process} -> process == pid end)
    |> Enum.into(%{})
  end
end
