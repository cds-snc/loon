defmodule Loon.Jobs.AzureCost do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the past months billing and cost forecast for Azure resources",
    schedule: "0 * * * *"

  @doc """
  Returns the past months billing and cost forecast for Azure resources
  """
  def job() do
    payload = %{
      client_id: Map.fetch!(System.get_env(), "AZURE_CLIENT_ID"),
      client_secret: Map.fetch!(System.get_env(), "AZURE_CLIENT_SECRET"),
      grant_type: "client_credentials",
      resource: "https://management.azure.com"
    }

    auth_url =
      "https://login.microsoftonline.com/#{Map.fetch!(System.get_env(), "AZURE_TENANT_ID")}/oauth2/token"

    billing_url =
      "https://management.azure.com/subscriptions/#{
        Map.fetch!(System.get_env(), "AZURE_SUBSCRIPTION_ID")
      }/providers/Microsoft.Billing/billingPeriods?api-version=2018-03-01-preview&$top=6"

    with {:ok, resp} <-
           HTTPoison.post(
             auth_url,
             URI.encode_query(payload),
             %{"Content-Type" => "application/x-www-form-urlencoded"},
             timeout: 50_000,
             recv_timeout: 50_000
           ),
         {:ok, %{"access_token" => access_token}} <- Jason.decode(resp.body),
         {:ok, resp} <-
           HTTPoison.get(billing_url, %{"Authorization" => "Bearer #{access_token}"},
             timeout: 50_000,
             recv_timeout: 50_000
           ),
         {:ok, data} <- Jason.decode(resp.body),
         periods <- Map.get(data, "value"),
         results <- pmap(periods, fn p -> fetch_usage_for_period(access_token, p) end)
    do
      results
      |> Enum.filter(&(&1 != nil))
    else
      err -> err
    end
  end

  defp fetch_usage_for_period(token, period) do
    [p, _] =
      period["name"]
      |> String.split("-")

    url =
      "https://management.azure.com/subscriptions/#{
        Map.fetch!(System.get_env(), "AZURE_SUBSCRIPTION_ID")
      }/providers/Microsoft.Billing/billingPeriods/#{p}/providers/Microsoft.Consumption/usageDetails?api-version=2019-01-01"

    with {:ok, resp} <-
           HTTPoison.get(url, %{"Authorization" => "Bearer #{token}"},
             timeout: 50_000,
             recv_timeout: 50_000
           ),
         {:ok, body} <- Jason.decode(resp.body),
         true <- Map.has_key?(body, "value") do
      %{
        month: period["properties"]["billingPeriodEndDate"],
        cost:
          Enum.reduce(body["value"], 0, fn obj, acc ->
            if Map.has_key?(obj, "properties") && Map.has_key?(obj["properties"], "pretaxCost") do
              acc + obj["properties"]["pretaxCost"]
            else
              acc
            end
          end) * 1.13
      }
    else
      _ -> nil
    end
  end

  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(fn t -> Task.await(t, 50_000) end)
  end
end
