defmodule Loon.Jobs.CraPerformanceIndex do
  @moduledoc false
  require Logger
  use Loon.Jobs,
    description: "Returns security goals performance index for the CRA Alpha",
    schedule: "0 * * * *"

  @doc """
  Returns security goals performance index for the CRA Alpha
  """
  def job() do
    url = "https://security-goals-demo.cdssandbox.xyz/security-goals/api"
    headers = ["Accept": "Application/json", "Content-Type": "application/json"]
    body = %{
      "query" => "query {releases {release timestamp passing total}}"
    }

    case HTTPoison.post(url, Jason.encode!(body), headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        resp = Jason.decode!(body)

        case resp["data"] do
          %{"releases" => releases} ->
            releases
          _ ->
            []
        end
      _ ->
        false
    end
  end
end
