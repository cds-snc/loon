defmodule Loon.Jobs.ConnectedDataSourcesTest do
  use LoonWeb.ChannelCase

  import Loon.Jobs.ConnectedDataSources

  test "job/0 returns an integer of connections to data sources" do
    assert is_integer(job())
  end
end
