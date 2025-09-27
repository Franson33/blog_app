defmodule BlogApp.Content do
  @moduledoc """
  Fetches and parses articles stored in GitHub repo.
  """

  def fetch_article(slug) do
    slug
    |> raw_url()
    |> fetch_markdown()
    |> parse_markdown()
  end

  defp fetch_markdown(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: md}} -> {:ok, md}
      {:ok, %HTTPoison.Response{status_code: code}} -> {:error, {:http_error, code}}
      {:error, reason} -> {:error, {:network_failure, reason}}
    end
  end

  defp parse_markdown({:ok, md}), do: do_parse(md)
  defp parse_markdown({:error, reason}), do: {:error, reason}

  defp do_parse(md) do
    case Earmark.as_html(md) do
      {:ok, html, _} -> {:ok, html}
      {:error, _msgs, _} -> {:error, :invalid_markdown}
    end
  end

  defp raw_url(slug) do
    "https://raw.githubusercontent.com/Franson33/articles/main/articles/#{slug}.md"
  end

  def list_articles() do
    [
      %{
        slug: "i-love-state-machines",
        title: "I love finite-state machines"
      },
      %{
        slug: "closure-based-architecture",
        title:
          "React's Component Revolution: How Closures Became the Foundation of Modern UI Components"
      }
    ]
  end
end
