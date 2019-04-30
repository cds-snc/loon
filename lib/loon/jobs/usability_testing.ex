defmodule Loon.Jobs.UsabilityTesting do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns usability testing data from Airtable",
    schedule: "0 * * * *"

  @doc """
  Returns usability testing data from Airtable
  """
  def job() do
    token = Map.fetch!(System.get_env(), "AIRTABLE_DASHBOARD_KEY")
    url = "https://api.airtable.com/v0/appwJrZHgj8Ijew93/Studies?cellFormat=string&timeZone=America/Toronto&userLocale=en-ca"
    headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json"]

    case HTTPoison.get(url, headers) do
      {:ok, resp} ->
        Jason.decode!(resp.body)
      _ ->
        %{}
    end
  end
end
