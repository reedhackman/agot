defmodule Agot.Players do
  alias Agot.Players.Player
  alias Agot.Repo
  import Ecto.Query

  def get_player(id, name) do
    query =
      from player in Player,
        where: player.id == ^id

    case Repo.one(query) do
      nil ->
        create_player(id, name)

      player ->
        player
    end
  end

  def get_player(id) do
    query =
      from player in Player,
        where: player.id == ^id

    case Repo.one(query) do
      nil ->
        nil

      player ->
        player
    end
  end

  def list_players do
    Repo.all(Player)
    |> Enum.map(fn x ->
      %{id: x.id, name: x.name, rating: x.rating, percent: x.percent, played: x.played}
    end)
  end

  def get_wins_for_player(id) do
    query =
      from player in Player,
        where: player.id == ^id,
        left_join: wins in assoc(player, :wins),
        left_join: loser in assoc(wins, :loser),
        select: %{
          faction: wins.winner_faction,
          agenda: wins.winner_agenda,
          loser: %{id: loser.id, name: loser.name}
        }

    Repo.all(query)
  end

  def get_losses_for_player(id) do
    query =
      from player in Player,
        where: player.id == ^id,
        left_join: losses in assoc(player, :losses),
        left_join: winner in assoc(losses, :winner),
        select: %{
          faction: losses.loser_faction,
          agenda: losses.loser_agenda,
          winner: %{id: winner.id, name: winner.name}
        }

    Repo.all(query)
  end

  def get_full_player(id) do
    wins = get_wins_for_player(id)
    losses = get_losses_for_player(id)
    player = get_player(id)
    ratings_over_time = player.ratings_over_time
    %{wins: wins, losses: losses, ratings_over_time: ratings_over_time}
  end

  def top_10 do
    query =
      from player in Player,
        order_by: [desc: player.rating],
        limit: 10

    Repo.all(query)
  end

  def create_player(id, name) do
    {:ok, player} =
      %Player{}
      |> Player.create_changeset(%{id: id, name: name})
      |> Repo.insert()

    player
  end

  def update_player(id, attrs) do
    Repo.one(from p in Player, where: p.id == ^id)
    |> Player.update_changeset(attrs)
    |> Repo.update()
  end

  def get_winner(id) do
    query =
      from player in Player,
        where: player.id == ^id,
        left_join: wins in assoc(player, :wins),
        preload: [wins: wins]

    Repo.one(query)
  end

  def get_loser(id) do
    query =
      from player in Player,
        where: player.id == ^id,
        left_join: losses in assoc(player, :losses),
        preload: [losses: losses]

    Repo.one(query)
  end
end
