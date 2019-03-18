defmodule Loon.Jobs.Test do
  @moduledoc false

  use Loon.Jobs,
    description: "A test job that returns ok",
    schedule: {:extended, "*/10"}

  @doc """
  Returns ok 
  """
  def job do
    "ok"
  end
end
