defmodule Loon.Jobs.GithubVacDeploys do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns GitHub data on merges to master for https://github.com/veteransaffairscanada/vac-benefits-directory every hour",
    schedule: "0 * * * *"

  @doc """
  Returns GitHub data on merges to master for https://github.com/veteransaffairscanada/vac-benefits-directory every hour
  """
  def job() do
    token = Map.fetch!(System.get_env(), "GITHUB_PUBLIC_ACCESS_TOKEN")
    url = "https://api.github.com/graphql"
    headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json"]
    body = "{\"query\": \"query {repository(owner: \\\"veteransaffairscanada\\\", name: \\\"vac-benefits-directory\\\") { pullRequests(baseRefName: \\\"master\\\", states: [CLOSED, MERGED], first: 20, after: \\\"Y3Vyc29yOnYyOpHOCrPLKw==\\\") {nodes {title mergedAt url} pageInfo { endCursor hasNextPage}}}}\"}"

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)
      _ ->
        false
    end
  end
end
