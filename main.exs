defmodule Main do
  def run() do
    Registry.start_link(name: :my_registry, keys: :unique)

    spawn(fn ->
      Registry.register(:my_registry, {:db_worker, 1}, nil)

      receive do
        msg -> IO.puts("[db_worker] #{inspect(msg)}")
      end
    end)
  end
end
