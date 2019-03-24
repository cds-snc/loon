defmodule Loon.Jobs.CdsUp do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the uptime robot data for uptime",
    schedule: "*/5 * * * *"

  @doc """
  Returns the up state of CDS websites based on the uptimerobot API
  """
  def job() do
    args = %{
      api_key: Map.fetch!(System.get_env(), "UPTIME_KEY"),
      format: "json",
      logs: "1"
    }

    case HTTPoison.post("https://api.uptimerobot.com/v2/getMonitors", URI.encode_query(args), [{"Content-Type", "application/x-www-form-urlencoded"}]) do
      {:ok, resp} ->
        Jason.decode!(resp.body)
      _ ->
        %{}
    end
  end
end
