defmodule ReservamosApi.Repo.Migrations.CreateHospedajes do
  use Ecto.Migration

  def change do
    create table(:hospedajes) do
      add :url, :text  # Changed from :string to :text
      add :title, :text  # Changed from :string to :text
      add :price_per_night, :float
      add :currency, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :amenities, :jsonb  # Changed from {:array, :string} to :jsonb
      add :rating_cleanliness, :float
      add :rating_accuracy, :float
      add :rating_check_in, :float
      add :rating_communication, :float
      add :rating_location, :float
      add :rating_value, :float
      add :rating_overall, :float
      add :total_reviews, :integer
      timestamps()
    end

    # 🔹 Performance Optimizations
    create index(:hospedajes, [:city])  # Index to speed up city-based queries
    create index(:hospedajes, [:country])  # Index for country-based queries
  end
end
