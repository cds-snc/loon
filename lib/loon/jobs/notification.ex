defmodule Loon.Jobs.Notification do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the stats from the notification service every hour",
    schedule: "0 * * * *"

  @doc """
  Returns the data from the notification stats service
  """
  def job do
    url = "https://api.notification.alpha.canada.ca/_status/live-service-and-organisation-counts"
    headers = ["Accept": "Application/json"]

    case HTTPoison.get(url, headers) do
      {:ok, resp} ->
        Jason.decode!(resp.body)
      _ ->
        %{}
    end
  end
end
