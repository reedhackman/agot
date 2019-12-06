defmodule Agot.Games.Incomplete do
  use Ecto.Schema
  import Ecto.Changeset

  alias Agot.Tournaments.Tournament

  @fields [
    :tournament_id,
    :tournament_date,
    :id
  ]

  schema "incomplete_games" do
    belongs_to :tournament, Tournament
    field :tournament_date, :utc_datetime
  end

  def changeset(incomplete_game, attrs) do
    incomplete_game
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
