defmodule AgotWeb.PageController do
  use AgotWeb, :controller
  alias Agot.Players
  alias Agot.Decks

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
