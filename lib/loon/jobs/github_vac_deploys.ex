defmodule Loon.Jobs.GithubVacDeploys do
  @moduledoc false
  require Logger
  use Loon.Jobs,
    description: "Returns GitHub data on merges to master for https://github.com/veteransaffairscanada/vac-benefits-directory every hour",
    schedule: "0 * * * *"

  @doc """
  Returns GitHub data on merges to master for https://github.com/veteransaffairscanada/vac-benefits-directory every hour
  """
  def job() do
    query([])
  end

  def query(results, endcursor \\ "") do

    token = Map.fetch!(System.get_env(), "GITHUB_PUBLIC_ACCESS_TOKEN")
    url = "https://api.github.com/graphql"
    headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json"]
    body = "{\"query\": \"query {repository(owner: \\\"veteransaffairscanada\\\", name: \\\"vac-benefits-directory\\\") { pullRequests(baseRefName: \\\"master\\\", states: [CLOSED, MERGED], first: 100#{endcursor}) {nodes {mergedAt author {... on User {organizations(first: 10) {nodes {login}}}}} pageInfo { endCursor hasNextPage}}}}\"}"
    IO.puts(body)
    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        resp = Jason.decode!(body)

        case resp["data"]["repository"]["pullRequests"] do
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
