defmodule Loon.Jobs.HerokuCost do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the cost of Heroku per month once a day",
    schedule: "* 0 * * *"

  @doc """
  Returns the cost of Heroku per month once a day
  """
  def job() do
    heroku_key = Map.fetch!(System.get_env(), "HEROKU_KEY")
    headers = [{"Accept", "application/vnd.heroku+json; version=3"}, {"Authorization", "Bearer #{heroku_key}"}]

    case HTTPoison.get("https://api.heroku.com/teams/cds/invoices", headers) do
      {:ok, resp} ->
        Jason.decode!(resp.body)
      _ ->
        []
    end
  end
end
