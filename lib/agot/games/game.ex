defmodule Agot.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Agot.Players.Player
  alias Agot.Tournaments.Tournament

  @fields [
    :winner_faction,
    :winner_agenda,
    :loser_faction,
    :loser_agenda,
    :tournament_id,
    :date,
    :id
  ]

  @required_fields [
    :tournament_id,
    :date,
    :id
  ]

  schema "games" do
    field :winner_faction, :string
    field :winner_agenda, :string
    field :loser_faction, :string
    field :loser_agenda, :string
    field :date, :utc_datetime

    belongs_to :winner, Player
    belongs_to :loser, Player
    belongs_to :tournament, Tournament
  end

  def changeset(game, attrs, winner, loser, tournament) do
    game
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> put_assoc(:winner, winner)
    |> put_assoc(:loser, loser)
    |> put_assoc(:tournament, tournament)
  end
end
