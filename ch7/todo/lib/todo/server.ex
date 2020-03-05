defmodule Todo.Server do
  use GenServer

  # API
  def start do
    GenServer.start(__MODULE__, %{})
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  # Internal
  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    new_state = Todo.List.add_entry(state, entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end
