defmodule Loon.Jobs.ServerMemoryTest do
  use ExUnit.Case, async: true

  import Loon.Jobs.ServerMemory

  test "job/0 returns a map of keys with values representing memory allocation" do
    assert %{
             atom: _,
             atom_used: _,
             binary: _,
             code: _,
             ets: _,
             processes: _,
             processes_used: _,
             system: _,
             total: _
           } = job()
  end
end
