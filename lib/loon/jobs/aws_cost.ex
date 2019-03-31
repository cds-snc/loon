defmodule Loon.Jobs.AwsCost do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the past months billing and cost forecast for AWS resources",
    schedule: "0 * * * *"

  @doc """
  Returns the past months billing and cost forecast for AWS resources
  """
  def job do
    client = client()

    {:ok, last_month, _} =
      Loon.Support.CostExplorer.get_cost_and_usage(
        client,
        %{
          Granularity: "MONTHLY",
          TimePeriod: %{Start: beginning_of_month(-1), End: end_of_month(-1)},
          Metrics: ["UnblendedCost"]
        }
      )

      {:ok, current_month, _} =
        Loon.Support.CostExplorer.get_cost_and_usage(
          client,
          %{
            Granularity: "MONTHLY",
            TimePeriod: %{Start: beginning_of_month(), End: end_of_month()},
            Metrics: ["UnblendedCost"]
          }
        )

        {:ok, forecast, _} =
          Loon.Support.CostExplorer.get_cost_forecaset(
            client,
            %{
              Granularity: "MONTHLY",
              TimePeriod: %{Start: today(), End: end_of_month()},
              Metric: "UNBLENDED_COST"
            }
          )

    %{last_month: last_month, current_month: current_month, forecast: forecast}
  end

  defp beginning_of_month(shift \\ 0) do
    Timex.now
    |> Timex.shift(months: shift)
    |> Timex.beginning_of_month
    |> Timex.format!("%Y-%m-%d", :strftime)
  end

  defp end_of_month(shift \\ 0) do
    Timex.now
    |> Timex.shift(months: shift)
    |> Timex.end_of_month
    |> Timex.format!("%Y-%m-%d", :strftime)
  end

  defp today() do
    Timex.now
    |> Timex.shift(days: 1)
    |> Timex.format!("%Y-%m-%d", :strftime)
  end


  defp client do
    %AWS.Client{
      access_key_id: Map.fetch!(System.get_env(), "AWS_KEY"),
      secret_access_key: Map.fetch!(System.get_env(), "AWS_SECRET"),
      region: "us-east-1",
      endpoint: "amazonaws.com"
    }
  end
end
