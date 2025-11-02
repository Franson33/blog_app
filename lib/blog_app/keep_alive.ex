defmodule BlogApp.KeepAlive do
  @moduledoc """
  GenServer that pings the application every 10 minutes to prevent
  Render.com free tier from spinning down due to inactivity.

  Only runs in production environment.
  """

  use GenServer
  require Logger

  @ping_interval :timer.minutes(10)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_ping()
    Logger.info("KeepAlive GenServer started - will ping every 10 minutes")
    {:ok, %{}}
  end

  @impl true
  def handle_info(:ping, state) do
    ping_self()
    schedule_ping()
    {:noreply, state}
  end

  defp schedule_ping do
    Process.send_after(self(), :ping, @ping_interval)
  end

  defp ping_self do
    url = build_url()

    Logger.debug("KeepAlive: Pinging #{url}")

    case Req.get(url, receive_timeout: 5000) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("KeepAlive: Ping successful (#{status})")

      {:ok, %{status: status}} ->
        Logger.error("KeepAlive: Ping returned status #{status}")

      {:error, reason} ->
        Logger.error("KeepAlive: Ping failed with error #{inspect(reason)}")
    end
  end

  defp build_url do
    host = System.get_env("RENDER_EXTERNAL_HOSTNAME") || "antons-blog.onrender.com"
    "https://#{host}"
  end
end
