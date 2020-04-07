defmodule Main do
  def run() do
    run_query = fn query_def ->
       Process.sleep(2000)
      "[result] #{query_def}"
    end

    1..5
    |> Enum.map(&Task.async(fn -> run_query.("query #{&1}") end))
    |> Enum.map(&Task.await/1)
  end
end
