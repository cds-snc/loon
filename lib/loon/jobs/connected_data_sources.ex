defmodule Loon.Jobs.ConnectedDataSources do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the count of connected data sources every 5 seconds",
    schedule: {:extended, "*/5"}

  @doc """
  Returns the total count of connections to data source channels
  """
  def job do
    LoonWeb.UserSocket.count_connections()
    |> Enum.map(fn {key, value} ->
      name =
        key
        |> String.replace("data_source:", "")
        |> String.replace("_", " ")
        |> String.capitalize
      {name, value}
    end)
    |> Enum.into(%{})
  end
end
