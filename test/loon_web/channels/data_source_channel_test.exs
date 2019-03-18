defmodule LoonWeb.DataSourceChannelTest do
  use LoonWeb.ChannelCase

  setup do
    {:ok, socket: socket(LoonWeb.UserSocket)}
  end

  test "replies with :ok if the data source exists", %{socket: socket} do
    resp =
      socket
      |> subscribe_and_join(LoonWeb.DataSourceChannel, "data_source:time")

    assert match?({:ok, _, _socket}, resp)
  end

  test "replies with :error if the data source exist does not exist", %{socket: socket} do
    resp =
      socket
      |> subscribe_and_join(LoonWeb.DataSourceChannel, "data_source:foo")

    assert match?({:error, _reason}, resp)
  end
end
