defmodule BlogAppWeb.ArticleController do
  use BlogAppWeb, :controller
  alias BlogApp.Content

  def show(conn, %{"slug" => slug}) do
    case Content.fetch_article(slug) do
      {:ok, html} ->
        render(conn, :show, article_html: html, slug: slug)

      {:error, reason} ->
        conn
        |> put_status(404)
        |> text("Article not found: #{inspect(reason)}")
    end
  end
end
