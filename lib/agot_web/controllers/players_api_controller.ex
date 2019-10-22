defmodule AgotWeb.PlayersApiController do
  use AgotWeb, :controller

  alias Agot.Players
  alias Agot.Games

  def all(conn, _params) do
    players =
      Players.list_all()
      |> Enum.map(fn x ->
        %{id: x.id, name: x.name, rating: x.rating, percent: x.percent, played: x.played}
      end)

    conn
    |> put_status(200)
    |> json(%{players: players})
  end

  def specific(conn, params) do
    id = params["id"]
    IO.inspect(id)

    games = Games.for_player(id)
    player = Players.get_specific(id)

    conn
    |> put_status(200)
    |> json(%{games: games, player: player})
  end
end
