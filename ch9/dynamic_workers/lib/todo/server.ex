defmodule Todo.Server do
  use GenServer, restart: :temporary

  # API
  def start_link(name) do
    IO.puts("Starting new Todo.Server for #{name}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  # Internal
  @impl GenServer
  def init(name) do
    send(self(), {:init, name})
    {:ok, nil}
  end

  # Note: This is not necessary because the first message being handled is handle_info for state init, other requests will block until it's finished (but the caller is unblocked)
  # @impl GenServer
  # def handle_cast(_, state) when state == nil do
  #   {:reply, {:error, :server_initializing, }}
  # end

  @impl GenServer
  def handle_info({:init, name}, _) do
    state = {name, Todo.Database.get(name) || Todo.List.new()}
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    {name, todo_list} = state
    new_todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {_name, todo_list} = state
    {:reply, Todo.List.entries(todo_list, date), state}
  end

  def via_tuple(name) do
    Todo.ProcessRegistry.via_tuple(name)
  end
end
