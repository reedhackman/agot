defmodule Agot.Tjp do
  alias Agot.Repo
  alias Agot.Tjp.Analytica
  alias Agot.Tjp.Api
  alias Agot.Tjp.Position
  alias Agot.Tjp.Worker

  def get_position() do
    case Repo.one(Position) do
      nil ->
        {:ok, position} =
          %Position{}
          |> Position.changeset(%{page: 1, index: 0})
          |> Repo.insert()

        position

      position ->
        position
    end
  end

  def update_position(position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end
end
