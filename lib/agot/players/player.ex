defmodule Agot.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Agot.Games.Game
  alias Agot.Tournaments.Tournament

  @fields [
    :name,
    :id,
    :num_wins,
    :num_losses,
    :rating
  ]

  schema "players" do
    field :name, :string
    field :num_wins, :integer
    field :num_losses, :integer
    field :rating, :float
    field :percent, :float
    field :played, :integer
    field :ratings_over_time, :map

    has_many :wins, Game, foreign_key: :winner_id, references: :id
    has_many :losses, Game, foreign_key: :loser_id, references: :id
    many_to_many :tournaments, Tournament, join_through: "players_tournaments"
  end

  def create_changeset(player, attrs) do
    player
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def update_changeset(player, attrs) do
    player
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> cast(
      %{
        percent: attrs.num_wins / (attrs.num_losses + attrs.num_wins),
        played: attrs.num_wins + attrs.num_losses,
        ratings_over_time: attrs.ratings_over_time
      },
      [:percent, :played, :ratings_over_time]
    )
  end
end
