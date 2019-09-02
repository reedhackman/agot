defmodule Agot.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :page, :integer
      add :length, :integer
    end

    create table(:games) do
      add :date, :utc_datetime
      add :loser_agenda, :string
      add :loser_faction, :string
      add :winner_agenda, :string
      add :winner_faction, :string
    end

    create table(:players) do
      add :name, :string
      add :num_losses, :integer
      add :num_wins, :integer
      add :percent, :float
      add :played, :integer
      add :rating, :float
      add :ratings_over_time, :map
    end

    create table(:decks) do
      add :agenda, :string
      add :faction, :string
      add :ninety_percent, :float
      add :ninety_played, :integer
      add :num_losses, :integer
      add :num_wins, :integer
      add :percent, :float
      add :played, :integer
    end

    create table(:incomplete_games) do
      add :tournament_id, :integer
      add :tournament_date, :utc_datetime
    end

    create table(:excluded_tournaments) do
      add :name, :string
    end

    create table(:tournaments) do
      add :date, :utc_datetime
      add :name, :string
      add :results, {:array, :integer}
    end

    create unique_index(:players, [:id])
    create unique_index(:games, [:id])
    create unique_index(:decks, [:id])
    create unique_index(:tournaments, [:id])
  end
end
