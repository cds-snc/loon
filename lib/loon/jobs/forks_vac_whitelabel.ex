defmodule Loon.Jobs.GithubVacWhitelabelForks do
  @moduledoc false
  require Logger
  use Loon.Jobs,
    description: "Returns GitHub data on forks of https://github.com/cds-snc/find-benefits-and-services",
    schedule: "0 * * * *"

  @doc """
  Returns GitHub data on forks of https://github.com/cds-snc/find-benefits-and-services every hour
  """
  def job() do
    query([])
  end

  def query(results, endcursor \\ "") do

    token = Map.fetch!(System.get_env(), "GITHUB_PUBLIC_ACCESS_TOKEN")
    url = "https://api.github.com/graphql"
    headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json"]
    body = "{\"query\": \"query {repository(owner: \\\"cds-snc\\\", name: \\\"find-benefits-and-services\\\") {forks(first: 100#{endcursor}) {nodes {url createdAt nameWithOwner} pageInfo { endCursor hasNextPage}}}}\"}"

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
