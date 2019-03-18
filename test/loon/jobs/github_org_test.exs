defmodule Loon.Jobs.GithubOrgTest do
  use ExUnit.Case, async: true

  import Loon.Jobs.GithubOrg

  test "job/0 returns a map of GitHub data" do
    assert is_map(job())
  end
end
