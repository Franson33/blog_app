defmodule BlogApp.Content do
  @moduledoc """
  Fetches and parses articles stored in GitHub repo.
  """

  alias HTTPoison.Response

  @base_url "https://raw.githubusercontent.com/Franson33/articles/main"
  @manifest_url "#{@base_url}/manifest.json"

  def fetch_article(slug) do
    slug
    |> raw_url()
    |> fetch_markdown()
    |> parse_markdown()
  end

  def list_articles do
    case fetch_manifest() do
      {:ok, articles} -> {:ok, articles}
      {:error, _} -> {:error, :invalid_json}
    end
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
    "#{@base_url}/articles/#{slug}.md"
  end

  defp fetch_manifest do
    @manifest_url
    |> HTTPoison.get()
    |> handle_response()
  end

  defp handle_response({:ok, %Response{status_code: 200, body: json}}), do: decode_json(json)
  defp handle_response({:ok, %Response{status_code: code}}), do: {:error, {:http_error, code}}
  defp handle_response({:error, reason}), do: {:error, {:network_failure, reason}}

  defp decode_json(json) do
    case Jason.decode(json) do
      {:ok, articles} -> {:ok, articles}
      {:error, _} -> {:error, :invalid_json}
    end
  end
end
