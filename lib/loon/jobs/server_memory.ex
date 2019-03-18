defmodule Loon.Jobs.ServerMemory do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns a map of the current server memory usage every second",
    schedule: {:extended, "*/1"}

  @doc """
  Returns a map of memory size allocations in the Erlang VM
  """
  def job do
    :erlang.memory()
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end
end
