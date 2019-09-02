defmodule AgotWeb.DecksController do
  use AgotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", script_name: "decks")
  end
end
