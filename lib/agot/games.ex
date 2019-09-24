defmodule Agot.Games do
  alias Agot.Games.Game
  alias Agot.Games.Incomplete
  alias Agot.Players
  alias Agot.Tournaments
  alias Agot.Repo
  import Ecto.Query

  def create_incomplete(attrs) do
    %Incomplete{}
    |> Incomplete.changeset(attrs)
    |> Repo.insert()
  end

  def delete_incomplete(id) do
    Repo.one(from incomplete in Incomplete, where: incomplete.id == ^id)
    |> Repo.delete()
  end

  def list_all_incomplete do
    Repo.all(Incomplete)
  end

  def list_all_games do
    Repo.all(Game)
  end

  def get_game(id) do
    Repo.one(from game in Game, where: game.id == ^id)
  end

  def create_game(attrs, winner_id, loser_id, tournament_id) do
    case get_game(attrs.id) do
      nil -> winner = Players.get_winner(winner_id)
      loser = Players.get_loser(loser_id)
      tournament = Tournaments.get_tournament(tournament_id)
      game_attrs = %{
        winner_faction: cond do
          attrs.winner_faction -> attrs.winner_faction
          attrs.winner_agenda -> attrs.winner_agenda
          true -> nil
        end,
        winner_agenda: cond do
          attrs.winner_agenda -> attrs.winner_agenda
          true -> nil
        end,
        loser_faction: cond do
          attrs.loser_faction -> attrs.loser_faction
          attrs.loser_agenda -> attrs.loser_agenda
          true -> nil
        end,
        loser_agenda: cond do
          attrs.loser_agenda -> attrs.loser_agenda
          true -> nil
        end,
        id: attrs.id,
        date: attrs.date,
        tournament_id: attrs.tournament_id
      }
      %Game{}
      |> Game.changeset(game_attrs, winner, loser, tournament)
      |> Repo.insert()
      game_attrs

      _game -> nil
    end

  end

  def list_games_for_interval(start_date, end_date) do
    query =
      from game in Game,
        where: game.date >= ^start_date and game.date <= ^end_date and not is_nil(game.winner_faction) and not is_nil(game.loser_faction) and not is_nil(game.winner_agenda) and not is_nil(game.loser_agenda)

    Repo.all(query)
  end

  def list_games_for_deck_last_n(faction, agenda, days) do
    query =
      from game in Game,
      where: ((game.winner_faction == ^faction and game.winner_agenda == ^agenda)
        or (game.loser_faction == ^faction and game.loser_agenda == ^agenda))
        and game.date > ago(^days, "day")
    Repo.all(query)
  end
end
