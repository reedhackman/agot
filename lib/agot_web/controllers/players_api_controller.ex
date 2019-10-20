defmodule AgotWeb.PlayersApiController do
  use AgotWeb, :controller

  alias Agot.Players

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

    wins = Players.get_wins(id)
    losses = Players.get_losses(id)
    player = Players.get_specific(id)

    conn
    |> put_status(200)
    |> json(%{wins: wins, losses: losses, player: player})
  end
end
