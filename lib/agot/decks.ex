defmodule Agot.Decks do
  alias Agot.Decks.Deck
  alias Agot.Repo
  import Ecto.Query

  def list_decks do
    Repo.all(Deck)
  end

  def top_10_ninety do
    query =
      from deck in Deck,
        where: deck.ninety_played >= 30,
        order_by: [desc: deck.ninety_percent],
        limit: 10

    Repo.all(query)
  end

  def get_deck(faction, agenda) do
    query =
      from deck in Deck,
      where: deck.faction == ^faction and deck.agenda == ^agenda
    case Repo.one(query) do
      nil ->
        create_deck(faction, agenda)
      deck ->
        deck
    end
  end

  def create_deck(faction, agenda) do
    {:ok, deck} =
      %Deck{}
      |> Deck.create_changeset(%{faction: faction, agenda: agenda, num_wins: 0, num_losses: 0})
      |> Repo.insert()
    deck
  end

  def update_deck(faction, agenda, attrs) do
    Repo.one(from deck in Deck, where: deck.faction == ^faction and deck.agenda == ^agenda)
    |> Deck.update_changeset(attrs)
    |> Repo.update()
  end

  def update_ninety(faction, agenda, attrs) do
    if attrs.wins + attrs.losses > 0 do
      Repo.one(from deck in Deck, where: deck.faction == ^faction and deck.agenda == ^agenda)
      |> Deck.ninety_changeset(%{ninety_played: attrs.wins + attrs.losses, ninety_percent: attrs.wins / (attrs.wins + attrs.losses)})
      |> Repo.update()
    end
  end
end
