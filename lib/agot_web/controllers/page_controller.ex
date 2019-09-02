defmodule AgotWeb.PageController do
  use AgotWeb, :controller
  alias Agot.Players
  alias Agot.Decks

  def index(conn, _params) do
    players = Players.top_10()
    decks = Decks.top_10_ninety()
    render(conn, "index.html", %{players: players, decks: decks})
  end

  def faq(conn, _params) do
    render(conn, "faq.html")
  end
end
