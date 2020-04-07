defmodule TodoCacheTest do
  use ExUnit.Case

  test "get_server" do
    bob_pid = Todo.Cache.get_server("bob")

    assert bob_pid != Todo.Cache.get_server("alice")
    assert bob_pid == Todo.Cache.get_server("bob")
  end
end
