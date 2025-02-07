defmodule ReservamosApiWeb.Router do
  use ReservamosApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ReservamosApiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ReservamosApiWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # **Este bloque estaba comentado, lo activamos**
  scope "/api", ReservamosApiWeb do
    pipe_through :api
    get "/places", PlaceController, :search
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:reservamos_api, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ReservamosApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end