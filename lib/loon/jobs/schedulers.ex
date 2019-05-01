defmodule Loon.Jobs.Schedulers do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns a map of the current scheduler usage every second",
    schedule: {:extended, "*/1"}

  @doc """
  Returns a map of scheduler usage in the Erlang VM
  """
  def job do
    :scheduler.sample()
    |> elem(1)
    |> Enum.reduce([], fn data, acc -> [Tuple.to_list(data)] ++ acc end)
    |> Enum.reverse()
  end
end
