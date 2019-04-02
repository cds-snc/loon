defmodule Loon.Jobs.GoogleCloudCost do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the cost of Google Cloud once per day",
    schedule: "* 1 * * *"

  @doc """
  Returns the cost of Google Cloud once per day
  """
  def job() do
    query = "SELECT
        project.name,
        SUM(cost) AS COST,
        invoice.month
      FROM
        billing_data.gcp_billing_export_v1_013D76_D3C36E_321F6D
      GROUP BY
        project.name,
        invoice.month;
      "

    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    conn = GoogleApi.BigQuery.V2.Connection.new(token.token)

    # Make the API request
    {:ok, response} =
      GoogleApi.BigQuery.V2.Api.Jobs.bigquery_jobs_query(
        conn,
        "ssc-billing-reports",
        body: %GoogleApi.BigQuery.V2.Model.QueryRequest{query: query}
      )

    response.rows
    |> Enum.reduce([], fn row, acc ->
      [project, cost, month] = row.f
      acc ++ [%{
        project: project.v,
        cost: cost.v,
        month: month.v
      }]
    end)
  end
end
