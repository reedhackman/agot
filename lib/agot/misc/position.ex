defmodule Agot.Misc.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :page,
    :length
  ]

  schema "positions" do
    field :page, :integer
    field :length, :integer
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
