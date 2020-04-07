defmodule SimpleRegistry.GenServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name, pid) do
    GenServer.call(__MODULE__, {:register, name, pid})
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, name, pid}, _, state) do
    Map.put(state, name, pid)
    %{:reply, {:ok}_, state}
  end

  @impl true
  def handle_call({:whereis, name}, _, state) do
    case Map.fetch(state, name) do
      {:ok, pid} ->
        {:reply, pid, state}
      :error ->
        {:reply, nil, state}
    end
  end

  @impl true
  def handle_info({:EXIT, pid, reason}) do
  end
