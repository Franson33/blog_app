defmodule BlogAppWeb.PageController do
  use BlogAppWeb, :controller
  alias BlogApp.Content

  def home(conn, _params) do
    render(conn, :home, articles: Content.list_articles())
  end
end
