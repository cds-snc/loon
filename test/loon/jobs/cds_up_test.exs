defmodule Loon.Jobs.CdsUpTest do
  use ExUnit.Case, async: true

  import Loon.Jobs.CdsUp

  test "job/0 returns data on the default set of Urls" do
    assert job() == [%{site: "https://digital.canada.ca", up: true}, %{site: "https://numerique.canada.ca", up: true}]
  end

  test "job/1 can return data on a passed URL" do
    assert job(["https://google.ca"]) == [%{site: "https://google.ca", up: true}]
  end

  test "job/1 returns false for bad urls" do
    assert job(["https://.ca"]) == [%{site: "https://.ca", up: false}]
  end
end
