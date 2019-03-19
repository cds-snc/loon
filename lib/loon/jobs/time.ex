defmodule Loon.Jobs.Time do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the current time every second",
    schedule: {:extended, "*/1"}

  @doc """
  Returns the time in ISO 8601
  """
  def job do
    Timex.now()
  end
end
