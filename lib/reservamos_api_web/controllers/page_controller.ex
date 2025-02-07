defmodule ReservamosApiWeb.PageController do
  use ReservamosApiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end