defmodule MultiDict do
  def new, do: %{}

  def add_entry(multidict, key, value) do
    Map.update(multidict, key, [value], &[value | &1])
  end

  def entries(multidict, key) do
    Map.get(multidict, key, [])
  end
end
