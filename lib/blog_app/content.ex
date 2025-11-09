defmodule BlogApp.Content do
  @moduledoc """
  Fetches and parses articles stored in GitHub repo.
  """

  alias HTTPoison.Response

  @base_url "https://raw.githubusercontent.com/Franson33/articles/main"
  @manifest_url "#{@base_url}/manifest.json"

  # MDEx parsing options
  @mdex_opts [
    extension: [
      strikethrough: true,
      tagfilter: true,
      table: true,
      autolink: true,
      tasklist: true,
      footnotes: true,
      # Enables emoji like :smile:
      shortcodes: true
    ],
    parse: [
      smart: true,
      relaxed_tasklist_matching: true
    ],
    render: [
      # Sanitizes HTML for security
      unsafe_: false,
      # Adds language class to code blocks
      github_pre_lang: true
    ],
    syntax_highlight: [
      formatter: {:html_inline, theme: "molokai"}
    ]
  ]

  def fetch_article(slug) do
    slug
    |> raw_url()
    |> fetch_markdown()
    |> parse_markdown()
    |> parse_body()
  end

  def list_articles do
    case fetch_manifest() do
      {:ok, articles} -> {:ok, articles}
      {:error, _} -> {:error, :invalid_json}
    end
  end

  defp fetch_markdown(url) do
    case HTTPoison.get(url) do
      {:ok, %Response{status_code: 200, body: md}} -> {:ok, md}
      {:ok, %Response{status_code: code}} -> {:error, {:http_error, code}}
      {:error, reason} -> {:error, {:network_failure, reason}}
    end
  end

  defp parse_markdown({:ok, md}) do
    case YamlFrontMatter.parse(md) do
      {:ok, metadata, body_md} ->
        {:ok, {metadata |> keys_to_atoms(), body_md}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_markdown({:error, reason}) do
    {:error, reason}
  end

  defp parse_body({:ok, {metadata, body_md}}) do
    case MDEx.to_html(body_md, @mdex_opts) do
      {:ok, html} -> {:ok, %{html: html, metadata: metadata}}
      {:error, reason} -> {:error, reason}
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
    case Jason.decode(json, keys: :atoms) do
      {:ok, articles} -> {:ok, articles}
      {:error, _} -> {:error, :invalid_json}
    end
  end

  defp keys_to_atoms(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
