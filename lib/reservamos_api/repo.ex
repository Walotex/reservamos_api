defmodule ReservamosApi.Repo do
  use Ecto.Repo,
    otp_app: :reservamos_api,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically sets the database URL if available.
  """
  def init(_, opts) do
    database_url = System.get_env("DATABASE_URL") || "postgres://postgres:newpassword@localhost/reservamos_api_dev"
    {:ok, Keyword.put(opts, :url, database_url)}
  end
end
