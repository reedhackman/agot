defmodule AgotWeb.DecksApiController do
  use AgotWeb, :controller

  alias Agot.Decks
  alias Agot.Games

  def all(conn, _params) do
    decks =
      Decks.list_all()
      |> Enum.map(fn x ->
        %{faction: x.faction, agenda: x.agenda, num_wins: x.num_wins, num_losses: x.num_losses}
      end)
      |> IO.inspect()

    conn
    |> put_status(200)
    |> json(%{decks: decks})
  end
end
