defmodule LoonWeb.UserSocketTest do
  use LoonWeb.ChannelCase

  import LoonWeb.UserSocket

  setup do
    {:ok, socket: socket(LoonWeb.UserSocket)}
  end

  test "count_connections/0 returns the connections count for all channels", %{socket: socket} do
    socket
    |> subscribe_and_join(LoonWeb.DataSourceChannel, "data_source:test")

    assert match?(%{"data_source:test" => _count}, count_connections())
  end

  test "count_connections/1 returns the connections count for a specific channel", %{
    socket: socket
  } do
    socket
    |> subscribe_and_join(LoonWeb.DataSourceChannel, "data_source:test")

    assert is_integer(count_connections("data_source:test"))
  end
end
