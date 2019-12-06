defmodule Agot.Tjp.Broker do
  alias Agot.Tjp
  alias Agot.Tjp.Analytica
  alias Agot.Games
  alias Agot.Tjp.Api
  alias Agot.Tournaments

  def check_for_new_games do
    position = Tjp.get_position()
    {:ok, new_games, page, index} = Api.get_games_by_page([], position.page, position.index)
    Analytica.process_new_games(new_games)
    Tjp.update_position(position, %{page: page, index: index})
  end

  def check_all_incomplete_games do
    Tournaments.list_tournaments_with_incomplete_games()
    |> Enum.each(&check_incomplete_for_tournament(&1))
  end

  def check_incomplete_for_tournament(tournament) do
    incomplete_ids =
      tournament.incomplete
      |> Enum.map(& &1.id)

    {:ok, games} = Api.get_games_by_tournament_id([], tournament.id)

    games
    |> Enum.filter(&Enum.member?(incomplete_ids, &1["game_id"]))
    |> Enum.filter(&(&1["game_status"] == 100))
    |> Enum.each(&incomplete_to_complete(&1))
  end

  def incomplete_to_complete(game) do
    IO.inspect(game)
  end
end
