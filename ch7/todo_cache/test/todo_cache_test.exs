defmodule TodoCacheTest do
  use ExUnit.Case

  test "get_server" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.get_server(cache, "bob")

    assert bob_pid != Todo.Cache.get_server(cache, "alice")
    assert bob_pid == Todo.Cache.get_server(cache, "bob")
  end

  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.get_server(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2019-12-19], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2018-12-19])

    # This allows us to only check fields we care about
    assert [%{date: ~D[2019-12-19], title: "Dentist"}] = entries
  end
end
