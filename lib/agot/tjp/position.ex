defmodule Agot.Tjp.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :page,
    :index
  ]

  schema "positions" do
    field :page, :integer
    field :index, :integer
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
