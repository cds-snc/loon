defmodule LoonWeb.UserSocket do
  use Phoenix.Socket

  channel "data_source:*", LoonWeb.DataSourceChannel

  @doc """
  Handles the user socket connection request
  """
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @doc """
  Returns a count of connections per channel
  """
  def count_connections() do
    acc = fn {channel, _}, map -> Map.update(map, channel, 1, &(&1 + 1)) end
    :ets.foldl(acc, %{}, Loon.PubSub.Local0)
  end

  @doc """
  Counts the total number of connections to a specific channel
  """
  def count_connections(name) do
    connections = count_connections()

    case Map.get(connections, name) do
      nil -> 0
      count -> count
    end
  end

  @doc """
  Checks if there are less than 2 connections with a channel. This is used to check
  if a job associated with a channel should be discontinued
  """
  def last_user?(topic) do
    connections = count_connections()
    Map.has_key?(connections, topic) && connections[topic] < 2
  end

  def id(_socket), do: nil
end
