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

  def games_over_range(conn, params) do
    start_date = NaiveDateTime.from_iso8601!(params["start"] <> " 00:00:00")
    end_date = NaiveDateTime.from_iso8601!(params["end"] <> " 23:59:59")

    games =
      Games.list_games_for_interval(start_date, end_date)
      |> Enum.map(fn x ->
        %{
          winner_faction: x.winner_faction,
          winner_agenda: x.winner_agenda,
          loser_faction: x.loser_faction,
          loser_agenda: x.loser_agenda
        }
      end)

    conn
    |> put_status(200)
    |> json(%{games: games})
  end

  def games_for_deck(conn, params) do
    faction = params["faction"]
    agenda = params["agenda"]

    games =
      Games.list_games_for_deck(faction, agenda)
      |> Enum.map(fn x ->
        %{
          winner_faction: x.winner_faction,
          winner_agenda: x.winner_agenda,
          loser_faction: x.loser_faction,
          loser_agenda: x.loser_agenda,
          date: x.date
        }
      end)

    conn
    |> put_status(200)
    |> json(%{games: games})
  end
end
