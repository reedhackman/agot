defmodule AgotWeb.ApiController do
  use AgotWeb, :controller
  alias Agot.Players
  alias Agot.Games

  def all_players(conn, _params) do
    players = Players.list_players()

    conn
    |> put_status(200)
    |> json(players)
  end

  def specific_player(conn, params) do
    id = String.to_integer(params["id"])
    player = Players.get_full_player(id)

    conn
    |> put_status(200)
    |> json(player)
  end
end
