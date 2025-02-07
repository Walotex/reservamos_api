defmodule ReservamosApi.Hospedaje do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hospedajes" do
    field :url, :string
    field :title, :string
    field :price_per_night, :float
    field :currency, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :amenities, {:array, :string}  # If JSONB, use {:map, :string} instead
    field :rating_cleanliness, :float
    field :rating_accuracy, :float
    field :rating_check_in, :float
    field :rating_communication, :float
    field :rating_location, :float
    field :rating_value, :float
    field :rating_overall, :float
    field :total_reviews, :integer

    timestamps()
  end

  @doc """
  Creates a changeset for a hospedaje entry with validations.
  """
  def changeset(hospedaje, attrs) do
    hospedaje
    |> cast(attrs, [
      :url, :title, :price_per_night, :currency, :city, :state, :country, :amenities,
      :rating_cleanliness, :rating_accuracy, :rating_check_in, :rating_communication,
      :rating_location, :rating_value, :rating_overall, :total_reviews
    ])
    |> validate_required([:title, :price_per_night, :city, :country])
    |> validate_number(:price_per_night, greater_than_or_equal_to: 0)
    |> validate_number(:rating_overall, greater_than_or_equal_to: 0, less_than_or_equal_to: 5)
    |> handle_amenities()
  end

  defp handle_amenities(changeset) do
    case get_change(changeset, :amenities) do
      nil -> changeset
      amenities when is_binary(amenities) -> 
        put_change(changeset, :amenities, Jason.decode!(amenities))
      _ -> changeset
    end
  end
end
