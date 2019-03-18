defmodule Loon.Jobs.TimeTest do
  use ExUnit.Case, async: true

  import Loon.Jobs.Time

  test "job/0 returns the current timestamp" do
    assert Timex.diff(Timex.now(), job()) < 10_000
  end
end
