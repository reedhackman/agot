defmodule Agot.Misc do
  alias Agot.Misc.Position
  alias Agot.Repo
  import Ecto.Query

  def get_position do
    case Repo.one(Position) do
      nil ->
        create_position()
      position ->
        position
    end
  end

  def create_position do
    {:ok, position} =
      %Position{}
      |> Position.changeset(%{page: 1, length: 0})
      |> Repo.insert()
    position
  end

  def update_position(page, length) do
    get_position()
    |> Position.changeset(%{page: page, length: length})
    |> Repo.update()
  end
end
