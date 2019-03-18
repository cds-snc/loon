defmodule Loon.Jobs.Time do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the current time in 10 second intervals",
    schedule: {:extended, "*/10"}

  @doc """
  Returns the time in ISO 8601
  """
  def job do
    Timex.now()
  end
end
