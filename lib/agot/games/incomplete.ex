defmodule Agot.Games.Incomplete do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :tournament_id,
    :tournament_date,
    :id
  ]

  schema "incomplete_games" do
    field :tournament_id, :integer
    field :tournament_date, :utc_datetime
  end

  def changeset(incomplete_game, attrs) do
    incomplete_game
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
