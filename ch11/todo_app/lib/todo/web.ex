defmodule Todo.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/add_entry" do
    IO.puts("/add_entry")
  end

  get "/hello" do
    IO.puts("world")
    conn = Plug.Conn.fetch_query_params(conn)
    conn
    |> Plug.Conn.send_resp(200, "WORLD")
  end

  def child_spec(_arg) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__,
    )
  end
end
