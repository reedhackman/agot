defmodule Agot.Tjp do
  use GenServer
  alias Agot.Analytica
  alias Agot.Games
  alias Agot.Repo
  alias Agot.Tournaments

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    IO.inspect("SPINNING UP in 1 min")
    Process.send_after(self(), :joust, 1000 * 60) # 1 minute
    {:ok, state}
  end

  def handle_info(:joust, state) do
    check_tjp()
    check_all_incomplete()
    delete_all_old_incomplete()
    check_tournaments_without_results()
    Analytica.update_all_decks_three_months()
    Process.send_after(self(), :joust, 1000 * 60 * 60 * 3)
    IO.puts("CHECKING AGAIN IN THREE HOURS")
    {:noreply, state}
  end

  def check_tjp do
    position = Agot.Misc.get_position()
    IO.inspect(position)
    IO.inspect("checking tjp for new games")
    check_games_by_page([], position.page, position.length)
  end

  def check_tournaments_without_results do
    Tournaments.list_all_missing_results()
    |> Enum.each(fn x -> check_tournament_for_end(x.id) end)
  end

  def delete_all_old_incomplete do
    now = NaiveDateTime.utc_now()
    Games.list_all_incomplete()
    |> Enum.filter(fn x -> NaiveDateTime.diff(now, x.tournament_date) > 60 * 60 * 24 * 31 end)
    |> Enum.each(fn x -> Repo.delete(x) end)
  end

  def check_all_incomplete do
    games = Games.list_all_incomplete()
    games
    |> Enum.map(fn x -> x.tournament_id end)
    |> Enum.uniq()
    |> Enum.each(fn x -> check_tournamant_for_incomplete(x, games) end)
  end

  def check_tournamant_for_incomplete(tournament_id, all_incomplete) do
    relevant_incomplete =
      all_incomplete
      |> Enum.filter(fn x -> x.tournament_id == tournament_id end)
      |> Enum.map(fn x -> x.id end)
    check_games_for_tournament(tournament_id)
    |> Enum.filter(fn x -> Enum.member?(relevant_incomplete, x["game_id"]) and x["game_status"] == 100 end)
    |> Enum.each(fn x -> handle_incomplete(x) end)
  end

  def handle_incomplete(game) do
    Analytica.clean_and_process_game(game)
    Games.delete_incomplete(game["game_id"])
  end

  def check_games_by_page(list \\ [], page \\ 1, i \\ 0) do
    url = "https://thejoustingpavilion.com/api/v3/games?page=" <> Integer.to_string(page)

    case HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}], follow_redirect: true]) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Poison.decode!(body)
        length = length(data)
        new_data = Enum.slice(data, i..length)
        IO.inspect(url <> " length: " <> Integer.to_string(length))

        if length === 50 do
          check_games_by_page(list ++ new_data, page + 1)
        else
          if length(list ++ new_data) do
            Analytica.process_all_games(list ++ new_data, page, length)
          end
          IO.inspect(Integer.to_string(length(list ++ new_data)) <> " new games")
        end
      {:error, _reason} ->
        check_games_by_page(list, page, i)
    end
  end

  def check_games_for_tournament(tournament_id, list \\ [], page \\ 1) do
    url = "http://thejoustingpavilion.com/api/v3/games?tournament_id=" <> Integer.to_string(tournament_id) <> "&page=" <> Integer.to_string(page)

    case HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}], follow_redirect: true]) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Poison.decode!(body)
        length = length(data)
        IO.inspect(url <> " length: " <> Integer.to_string(length))
        if length === 50 do
          check_games_for_tournament(tournament_id, list ++ data, page + 1)
        else
          list ++ data
        end
      {:error, _reason} ->
        nil
    end
  end

  def check_tournament_for_end(id) do
    url = "http://thejoustingpavilion.com/api/v3/tournaments?tournament_id=" <> Integer.to_string(id)

    case HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}], follow_redirect: true]) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Poison.decode!(body)
        if List.first(data)["end_time"] !== nil do
          check_results_of_tournament(id)
        end
      {:error, _reason} ->
        nil
    end
  end

  def check_results_of_tournament(id) do
    url = "http://thejoustingpavilion.com/api/v3/tournaments/" <> Integer.to_string(id)

    case HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}], follow_redirect: true]) do
      {:ok, %{status_code: 200, body: body}} ->
        results =
          Poison.decode!(body)
          |> Enum.map(fn x -> x["player_id"] end)
        tournament = Tournaments.get_tournament(id)
        Tournaments.add_results_to_tournament(tournament, %{results: results})
        results
        |> Enum.each(fn x -> Tournaments.add_player_to_tournament(tournament, x) end)
    end
  end
end
