defmodule Loon.Jobs.CdsUp do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns if CDS websites are up",
    schedule: "* * * * *"

  @urls  [
      "https://digital.canada.ca",
      "https://numerique.canada.ca",
      "https://vac-handoff.herokuapp.com",
      "https://vancouver.rescheduler-dev.cds-snc.ca",
      "https://it.actually.works"
    ]

  @doc """
  Returns the up state of CDS websites
  """
  def job(urls \\ @urls) do
    urls
    |> Enum.reduce([], fn url, acc ->
      case HTTPoison.get(url) do
        {:ok, _conn} ->
          acc ++ [%{site: url, up: true}]
        _ ->
          acc ++ [%{site: url, up: false}]
      end
    end)
  end
end
