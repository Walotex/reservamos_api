defmodule ReservamosApi.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReservamosApi.Repo, 
      ReservamosApiWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:reservamos_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ReservamosApi.PubSub},
      {Finch, name: ReservamosApi.Finch},
      ReservamosApiWeb.Endpoint,
      {Cachex, name: :places_cache}
    ]

    opts = [strategy: :one_for_one, name: ReservamosApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ReservamosApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
