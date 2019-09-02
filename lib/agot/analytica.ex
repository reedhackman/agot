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
    games = Games.list_games_for_deck_interval(faction, agenda, 90)
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
    update_all_players()
    update_all_decks()
    Misc.update_position(page_number, page_length)
  end

  def update_all_players do
    :ets.match(:updated_players_cache, {:"_", :"$2"})
    |> List.flatten()
    |> Enum.each(fn x -> update_single_player(x) end)
  end

  def update_single_player(player) do
    attrs = %{
      num_wins: player.num_wins,
      num_losses: player.num_losses,
      rating: player.rating,
      ratings_over_time: player.ratings_over_time
    }
    Players.update_player(player.id, attrs)
    Cache.delete_updated_player(player.id)
  end

  def update_all_decks do
    :ets.match(:updated_decks_cache, {:"$1", :"$2"})
    |> Enum.each(fn x -> update_single_deck(x) end)
  end

  def update_single_deck(deck) do
    {faction, agenda} = List.first(deck)
    attrs = List.last(deck)
    Decks.update_deck(faction, agenda, attrs)
    Cache.delete_updated_deck({faction, agenda})
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
        Games.create_incomplete(%{tournament_id: game.tournament_id, id: game.game_id, tournament_date: game.tournament_date})
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
    if (game.winner.faction !== nil or game.winner.agenda === "The Free Folk") and
         (game.loser.faction !== nil or game.loser.agenda === "The Free Folk") do
      winner =
        case Cache.get_updated_player(game.winner.id) do
          nil ->
            Players.get_player(game.winner.id, game.winner.name)

          player ->
            player
        end

      loser =
        case Cache.get_updated_player(game.loser.id) do
          nil ->
            Players.get_player(game.loser.id, game.loser.name)

          player ->
            player
        end

      _tournament =
        case Cache.get_tournament(game.misc.tournament_id) do
          nil ->
            tournament = Tournaments.get_tournament(game.misc.tournament_id, game.misc.tournament_name, game.misc.tournament_date)
            Cache.put_tournament(tournament.id, tournament)
            tournament

          tournament ->
            tournament
        end

      rate(winner, loser, game.misc.tournament_date)

      if (game.winner.faction == game.loser.faction and game.winner.agenda == game.loser.agenda) ===
           false and (game.loser.agenda !== "" and game.winner.agenda !== "") do
        winner_faction =
          if game.winner.faction == nil do
            game.winner.agenda
          else
            game.winner.faction
          end
        loser_faction =
          if game.loser.faction == nil do
            game.loser.agenda
          else
            game.loser.faction
          end
        Games.create_game(
          %{
            winner_faction: winner_faction,
            winner_agenda: game.winner.agenda,
            loser_faction: loser_faction,
            loser_agenda: game.loser.agenda,
            tournament_id: game.misc.tournament_id,
            id: game.misc.id,
            date: game.misc.tournament_date
          },
          game.winner.id,
          game.loser.id,
          game.misc.tournament_id
        )

        process_decks_and(
          winner_faction,
          game.winner.agenda,
          loser_faction,
          game.loser.agenda
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

        Cache.put_updated_player(winner.id, %{
          id: winner.id,
          num_wins: winner.num_wins + 1,
          num_losses: winner.num_losses,
          rating: r_w,
          ratings_over_time: map
        })
      else
        map = Map.put(winner.ratings_over_time, date, r_w)

        Cache.put_updated_player(winner.id, %{
          id: winner.id,
          num_wins: winner.num_wins + 1,
          num_losses: winner.num_losses,
          rating: r_w,
          ratings_over_time: map
        })
      end
    else
      Cache.put_updated_player(winner.id, %{
        id: winner.id,
        num_wins: winner.num_wins + 1,
        num_losses: winner.num_losses,
        rating: r_w,
        ratings_over_time: %{date => r_w}
      })
    end

    if loser.ratings_over_time do
      if Map.has_key?(loser.ratings_over_time, date) do
        {_, map} = Map.get_and_update(loser.ratings_over_time, date, fn x -> {x, r_l} end)

        Cache.put_updated_player(loser.id, %{
          id: loser.id,
          num_wins: loser.num_wins,
          num_losses: loser.num_losses + 1,
          rating: r_l,
          ratings_over_time: map
        })
      else
        map = Map.put(loser.ratings_over_time, date, r_l)

        Cache.put_updated_player(loser.id, %{
          id: loser.id,
          num_wins: loser.num_wins,
          num_losses: loser.num_losses + 1,
          rating: r_l,
          ratings_over_time: map
        })
      end
    else
      Cache.put_updated_player(loser.id, %{
        id: loser.id,
        num_wins: loser.num_wins,
        num_losses: loser.num_losses + 1,
        rating: r_l,
        ratings_over_time: %{date => r_l}
      })
    end
  end

  def process_decks_and(winner_faction, winner_agenda, loser_faction, loser_agenda) do
    winner_tuple = {winner_faction, winner_agenda}

    loser_tuple = {loser_faction, loser_agenda}

    winner_deck =
      case Cache.get_updated_deck(winner_tuple) do
        nil ->
          deck = Decks.get_deck(winner_faction, winner_agenda)
          Cache.put_updated_deck(winner_tuple, %{num_wins: deck.num_wins, num_losses: deck.num_losses})
          deck
        deck ->
          deck
      end

    loser_deck =
      case Cache.get_updated_deck(loser_tuple) do
        nil ->
          deck = Decks.get_deck(loser_faction, loser_agenda)
          Cache.put_updated_deck(loser_tuple, %{num_wins: deck.num_wins, num_losses: deck.num_losses})
          deck
        deck ->
          deck
      end

    process_decks(
      {winner_faction, winner_agenda},
      {loser_faction, loser_agenda},
      winner_deck,
      loser_deck
    )
  end

  def process_decks(winner_tuple, loser_tuple, winner_deck, loser_deck) do
    Cache.put_updated_deck(winner_tuple, %{
      num_wins: winner_deck.num_wins + 1,
      num_losses: winner_deck.num_losses
    })

    Cache.put_updated_deck(loser_tuple, %{
      num_wins: loser_deck.num_wins,
      num_losses: loser_deck.num_losses + 1
    })
  end
end