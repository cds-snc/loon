defmodule Loon.Jobs.GithubVacForks do
  @moduledoc false
  require Logger
  use Loon.Jobs,
    description: "Returns GitHub data on forks of https://github.com/veteransaffairscanada/vac-benefits-directory",
    schedule: "0 * * * *"

  @doc """
  Returns GitHub data on forks of https://github.com/veteransaffairscanada/vac-benefits-directory every hour
  """
  def job() do
    query([])
  end

  def query(results, endcursor \\ "") do

    token = Map.fetch!(System.get_env(), "GITHUB_PUBLIC_ACCESS_TOKEN")
    url = "https://api.github.com/graphql"
    headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json"]
    body = "{\"query\": \"query {repository(owner: \\\"veteransaffairscanada\\\", name: \\\"vac-benefits-directory\\\") {forks(first: 100#{endcursor}) {nodes {url createdAt nameWithOwner} pageInfo { endCursor hasNextPage}}}}\"}"

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        resp = Jason.decode!(body)

        case resp["data"]["repository"]["forks"] do
          %{"nodes" => nodes, "pageInfo" => %{"endCursor" => cursor, "hasNextPage" => true}} ->
            query(results ++ nodes, ", after: \\\"#{cursor}\\\"")
          %{"nodes" => nodes, "pageInfo" => %{"hasNextPage" => false}} ->
            results ++ nodes
          _ ->
            results
        end
      _ ->
        false
    end
  end
end
