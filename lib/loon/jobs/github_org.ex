defmodule Loon.Jobs.GithubOrg do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the GitHub organization data for CDS every hour",
    schedule: "0 * * * *"

  @doc """
  Returns the GitHub data for an organization
  """
  def job() do
    case HTTPoison.get("https://api.github.com/orgs/cds-snc") do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)
      _ ->
        false
    end
  end
end
