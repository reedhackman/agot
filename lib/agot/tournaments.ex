defmodule Agot.Tournaments do
  alias Agot.Tournaments.Tournament
  alias Agot.Tournaments.Exclude
  alias Agot.Players
  alias Agot.Repo
  import Ecto.Query

  def get_excluded(id, name) do
    query =
      from excluded in Exclude,
        where: excluded.id == ^id

    case Repo.one(query) do
      nil ->
        create_excluded(id, name)

      excluded ->
        excluded
    end
  end

  def create_excluded(id, name) do
    {:ok, excluded} =
      %Exclude{}
      |> Exclude.changeset(%{id: id, name: name})
      |> Repo.insert()

    excluded
  end

  def get_tournament(id, name \\ "", date \\ "") do
    query =
      from tournament in Tournament,
        where: tournament.id == ^id,
        left_join: players in assoc(tournament, :players),
        preload: [players: players]

    case Repo.one(query) do
      nil ->
        create_tournament(id, name, date)

      tournament ->
        tournament
    end
  end

  def create_tournament(id, name, date) do
    {:ok, tournament} =
      %Tournament{}
      |> Tournament.changeset(%{id: id, name: name, date: date})
      |> Repo.insert()

    tournament
  end

  def update_tournament(id, attrs) do
    get_tournament(id)
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  def list_tournaments_with_incomplete_games do
    query =
      from tournament in Tournament,
        left_join: incomplete in assoc(tournament, :incomplete),
        preload: [incomplete: incomplete]

    Repo.all(query)
    |> Enum.filter(&(length(&1.incomplete) > 0))
  end
end
