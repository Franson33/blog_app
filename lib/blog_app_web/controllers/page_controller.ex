defmodule BlogAppWeb.PageController do
  use BlogAppWeb, :controller
  alias BlogApp.Content

  def home(conn, _params) do
    case Content.list_articles() do
      {:ok, articles} ->
        render(conn, :home, articles: articles)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not load articles")
        |> render(:home, articles: [])
    end
  end
end
