defmodule Agot.Analytica do
  alias Agot.Cache
  alias Agot.Tournaments
  alias Agot.Games
  alias Agot.Players
  alias Agot.Decks
  alias Agot.Misc

  def update_all_decks_three_months do
    Decks.list_decks()
    |> Enum.each(fn x -> update_single_deck_three_months(x.faction, x.agenda) end)
  end

  def update_single_deck_three_months(faction, agenda) do
    games = Games.list_games_for_deck_last_n(faction, agenda, 90)

    wins =
      games
      |> Enum.count(fn x -> x.winner_faction == faction and x.winner_agenda == agenda end)

    losses = length(games) - wins
    Decks.update_ninety(faction, agenda, %{wins: wins, losses: losses})
  end

  def process_all_games(data, page_number, page_length) do
    Enum.each(data, fn x -> check_for_exclude(x) end)

    exclude_map =
      :ets.match(:exclude_cache, {:"_", :"$2"})
      |> List.flatten()

    exclude_list =
      exclude_map
      |> Enum.map(fn x -> x.id end)

    Enum.each(data, fn x -> clean_and_process_game(x, exclude_list) end)
    Misc.update_position(page_number, page_length)
  end

  def check_for_exclude(game) do
    name = game["tournament_name"]
    id = game["tournament_id"]

    cond do
      Regex.match?(~r/l5r/i, name) or
        Regex.match?(~r/keyforge/i, name) or
        Regex.match?(~r/melee/i, name) or
        Regex.match?(~r/destiny/i, name) or
        Regex.match?(~r/draft/i, name) or
        game["p1_agenda"] == "Uniting the Seven Kingdoms" or
        game["p1_agenda"] == "Treaty" or
        game["p1_agenda"] == "Protectors of the Realm" or
        game["p1_agenda"] == "The Power of Wealth" or
        game["p2_agenda"] == "Uniting the Seven Kingdoms" or
        game["p2_agenda"] == "Treaty" or
        game["p2_agenda"] == "Protectors of the Realm" or
          game["p2_agenda"] == "The Power of Wealth" ->
        if Cache.get_exclude(id) == nil do
          excluded = Tournaments.get_excluded(id, name)
          Cache.put_exclude(excluded.id, %{name: excluded.name, id: excluded.id})
        end

      true ->
        nil
    end
  end

  def clean_and_process_game(game, exclude_list \\ []) do
    if Enum.member?(exclude_list, game["tournament_id"]) do
      nil
    else
      temp =
        strings_to_atoms(game)
        |> check_game()

      cond do
        temp === nil -> nil
        true -> process_game(temp)
      end
    end
  end

  def check_game(game) do
    cond do
      game.game_status !== 100 ->
        Games.create_incomplete(%{
          tournament_id: game.tournament_id,
          id: game.game_id,
          tournament_date: game.tournament_date
        })

        nil

      game.p1_id < 1 or game.p2_id < 1 or String.downcase(game.p1_name) =~ "bye" or
        String.downcase(game.p1_name) =~ "dummy" or String.downcase(game.p2_name) =~ "bye" or
          String.downcase(game.p2_name) =~ "dummy" ->
        nil

      game.p1_points > game.p2_points ->
        _game = %{
          winner: %{
            id: game.p1_id,
            name: game.p1_name,
            faction: game.p1_faction,
            agenda: game.p1_agenda
          },
          loser: %{
            id: game.p2_id,
            name: game.p2_name,
            faction: game.p2_faction,
            agenda: game.p2_agenda
          },
          misc: %{
            id: game.game_id,
            tournament_id: game.tournament_id,
            tournament_date: game.tournament_date,
            tournament_name: game.tournament_name
          }
        }

      game.p2_points > game.p1_points ->
        _game = %{
          loser: %{
            id: game.p1_id,
            name: game.p1_name,
            faction: game.p1_faction,
            agenda: game.p1_agenda
          },
          winner: %{
            id: game.p2_id,
            name: game.p2_name,
            faction: game.p2_faction,
            agenda: game.p2_agenda
          },
          misc: %{
            id: game.game_id,
            tournament_id: game.tournament_id,
            tournament_date: game.tournament_date,
            tournament_name: game.tournament_name
          }
        }

      game.p1_points === game.p2_points ->
        nil
    end
  end

  def strings_to_atoms(attrs) do
    cond do
      attrs["p1_agenda"] == nil and attrs["p2_agenda"] == nil ->
        %{
          game_status: attrs["game_status"],
          p1_points: attrs["p1_points"],
          p2_points: attrs["p2_points"],
          p1_id: attrs["p1_id"],
          p2_id: attrs["p2_id"],
          p1_name: attrs["p1_name"],
          p2_name: attrs["p2_name"],
          p1_faction: attrs["p1_faction"],
          p1_agenda: "",
          p2_faction: attrs["p2_faction"],
          p2_agenda: "",
          tournament_id: attrs["tournament_id"],
          tournament_date: attrs["tournament_date"],
          tournament_name: attrs["tournament_name"],
          game_id: attrs["game_id"]
        }

      attrs["p1_agenda"] == nil ->
        %{
          game_status: attrs["game_status"],
          p1_points: attrs["p1_points"],
          p2_points: attrs["p2_points"],
          p1_id: attrs["p1_id"],
          p2_id: attrs["p2_id"],
          p1_name: attrs["p1_name"],
          p2_name: attrs["p2_name"],
          p1_faction: attrs["p1_faction"],
          p1_agenda: "",
          p2_faction: attrs["p2_faction"],
          p2_agenda: attrs["p2_agenda"],
          tournament_id: attrs["tournament_id"],
          tournament_date: attrs["tournament_date"],
          tournament_name: attrs["tournament_name"],
          game_id: attrs["game_id"]
        }

      attrs["p2_agenda"] == nil ->
        %{
          game_status: attrs["game_status"],
          p1_points: attrs["p1_points"],
          p2_points: attrs["p2_points"],
          p1_id: attrs["p1_id"],
          p2_id: attrs["p2_id"],
          p1_name: attrs["p1_name"],
          p2_name: attrs["p2_name"],
          p1_faction: attrs["p1_faction"],
          p1_agenda: attrs["p1_agenda"],
          p2_faction: attrs["p2_faction"],
          p2_agenda: "",
          tournament_id: attrs["tournament_id"],
          tournament_date: attrs["tournament_date"],
          tournament_name: attrs["tournament_name"],
          game_id: attrs["game_id"]
        }

      true ->
        %{
          game_status: attrs["game_status"],
          p1_points: attrs["p1_points"],
          p2_points: attrs["p2_points"],
          p1_id: attrs["p1_id"],
          p2_id: attrs["p2_id"],
          p1_name: attrs["p1_name"],
          p2_name: attrs["p2_name"],
          p1_faction: attrs["p1_faction"],
          p1_agenda: attrs["p1_agenda"],
          p2_faction: attrs["p2_faction"],
          p2_agenda: attrs["p2_agenda"],
          tournament_id: attrs["tournament_id"],
          tournament_date: attrs["tournament_date"],
          tournament_name: attrs["tournament_name"],
          game_id: attrs["game_id"]
        }
    end
  end

  def process_game(game) do
    winner = Players.get_player(game.winner.id, game.winner.name)

    loser = Players.get_player(game.loser.id, game.loser.name)

    tournament =
      Tournaments.get_tournament(
        game.misc.tournament_id,
        game.misc.tournament_name,
        game.misc.tournament_date
      )

    case Games.create_game(
           %{
             winner_faction: game.winner.faction,
             winner_agenda: game.winner.agenda,
             loser_faction: game.loser.faction,
             loser_agenda: game.loser.agenda,
             tournament_id: game.misc.tournament_id,
             id: game.misc.id,
             date: game.misc.tournament_date
           },
           game.winner.id,
           game.loser.id,
           game.misc.tournament_id
         ) do
      nil ->
        nil

      new_game ->
        rate(winner, loser, game.misc.tournament_date)

        if is_nil(new_game.winner_faction) === false and is_nil(new_game.loser_faction) and
             new_game.winner_faction !== "" and new_game.loser_faction !== "" do
          process_decks(
            new_game.winner_faction,
            new_game.winner_agenda,
            new_game.loser_faction,
            new_game.loser_agenda
          )
        end
    end
  end

  def rate(winner, loser, date) do
    k = 40
    e_w = 1 / (1 + :math.pow(10, (loser.rating - winner.rating) / 400))
    e_l = 1 / (1 + :math.pow(10, (winner.rating - loser.rating) / 400))
    r_w = winner.rating + k * (1 - e_w)
    r_l = loser.rating + k * (0 - e_l)

    if winner.ratings_over_time do
      if Map.has_key?(winner.ratings_over_time, date) do
        {_, map} = Map.get_and_update(winner.ratings_over_time, date, fn x -> {x, r_w} end)

        Players.update_player(winner.id, %{
          num_wins: winner.num_wins + 1,
          num_losses: winner.num_losses,
          ratings_over_time: map,
          rating: r_w
        })
      else
        map = Map.put(winner.ratings_over_time, date, r_w)

        Players.update_player(winner.id, %{
          num_wins: winner.num_wins + 1,
          num_losses: winner.num_losses,
          ratings_over_time: map,
          rating: r_w
        })
      end
    else
      Players.update_player(winner.id, %{
        num_wins: winner.num_wins + 1,
        num_losses: winner.num_losses,
        ratings_over_time: %{date => r_w},
        rating: r_w
      })
    end

    if loser.ratings_over_time do
      if Map.has_key?(loser.ratings_over_time, date) do
        {_, map} = Map.get_and_update(loser.ratings_over_time, date, fn x -> {x, r_l} end)

        Players.update_player(loser.id, %{
          num_wins: loser.num_wins,
          num_losses: loser.num_losses + 1,
          ratings_over_time: map,
          rating: r_l
        })
      else
        map = Map.put(loser.ratings_over_time, date, r_l)

        Players.update_player(loser.id, %{
          num_wins: loser.num_wins,
          num_losses: loser.num_losses + 1,
          ratings_over_time: map,
          rating: r_l
        })
      end
    else
      Players.update_player(loser.id, %{
        num_wins: loser.num_wins,
        num_losses: loser.num_losses + 1,
        ratings_over_time: %{date => r_l},
        rating: r_l
      })
    end
  end

  def process_decks(winner_faction, winner_agenda, loser_faction, loser_agenda) do
    winner_deck = Decks.get_deck(winner_faction, winner_agenda)
    loser_deck = Decks.get_deck(loser_faction, loser_agenda)

    Decks.update_deck(winner_faction, winner_agenda, %{
      num_wins: winner_deck.num_wins + 1,
      num_losses: winner_deck.num_losses
    })

    Decks.update_deck(loser_faction, loser_agenda, %{
      num_wins: loser_deck.num_wins,
      num_losses: loser_deck.num_losses + 1
    })
  end
end
