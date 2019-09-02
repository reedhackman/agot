defmodule AgotWeb.PlayersController do
  use AgotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", %{script_name: "players"})
  end
end
