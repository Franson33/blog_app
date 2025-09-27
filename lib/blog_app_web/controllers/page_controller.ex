defmodule BlogAppWeb.PageController do
  use BlogAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
