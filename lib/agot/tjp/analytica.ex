defmodule Agot.Tjp.Analytica do
  alias Agot.Decks
  alias Agot.Games
  alias Agot.Players
  alias Agot.Tournaments

  alias Agot.Tjp.Cache

  def process_new_games(new_games) do
    Enum.each(new_games, fn x -> check_if_excluded(x) end)

    excluded_list =
      :ets.match(:excluded_cache, {:"$1", :"$2"})
      |> Enum.map(&Enum.at(&1, 1))
      |> Enum.map(fn x -> x.id end)

    Enum.each(new_games, fn x -> clean_and_process_game(x, excluded_list) end)
  end

  def check_if_excluded(game) do
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
        if Cache.get_excluded(id) == nil do
          excluded = Tournaments.get_excluded(id, name)
          Cache.put_excluded(excluded.id, %{name: excluded.name, id: excluded.id})
        end

      true ->
        nil
    end
  end

  def clean_and_process_game(game, excluded_list \\ []) do
    if Enum.member?(excluded_list, game["tournament_id"]) do
      nil
    else
      cleaned_game =
        strings_to_atoms(game)
        |> check_game()

      cond do
        cleaned_game === nil -> nil
        true -> process_game(cleaned_game)
      end
    end

    {:ok}
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
        %{
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
        %{
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
      case Cache.get_tournament(game.misc.tournament_id) do
        nil ->
          tournament =
            Tournaments.get_tournament(
              game.misc.tournament_id,
              game.misc.tournament_name,
              game.misc.tournament_date
            )

          Cache.put_tournament(game.misc.tournament_id, tournament)
          tournament

        tournament ->
          tournament
      end

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
        rate(winner, loser, game.misc.id)

        if is_nil(new_game.winner_faction) === false and is_nil(new_game.loser_faction) === false and
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

  def rate(winner, loser, game_id) do
    k = 20
    e_w = 1 / (1 + :math.pow(10, (loser.rating - winner.rating) / 400))
    e_l = 1 / (1 + :math.pow(10, (winner.rating - loser.rating) / 400))
    r_w = winner.rating + k * (1 - e_w)
    r_l = loser.rating + k * (0 - e_l)

    Players.update_player(winner.id, %{
      num_wins: winner.num_wins + 1,
      num_losses: winner.num_losses,
      rating: r_w,
      ratings_list: winner.ratings_list ++ [%{game_id: game_id, rating: r_w}]
    })

    Players.update_player(loser.id, %{
      num_wins: loser.num_wins,
      num_losses: loser.num_losses + 1,
      rating: r_l,
      ratings_list: loser.ratings_list ++ [%{game_id: game_id, rating: r_l}]
    })
  end

  def process_decks(winner_faction, winner_agenda, loser_faction, loser_agenda) do
    winner_deck = Decks.get_deck(winner_faction, winner_agenda)
    loser_deck = Decks.get_deck(loser_faction, loser_agenda)

    Decks.update_deck(winner_deck, %{
      num_wins: winner_deck.num_wins + 1,
      num_losses: winner_deck.num_losses
    })

    Decks.update_deck(loser_deck, %{
      num_wins: loser_deck.num_wins,
      num_losses: loser_deck.num_losses + 1
    })
  end
end
