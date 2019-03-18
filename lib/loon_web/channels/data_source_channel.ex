defmodule LoonWeb.DataSourceChannel do
  use LoonWeb, :channel

  @doc """
  Handles the joining of channels for specific data sources. It first
  checks if the name of the data source being joined is a valid Job. If
  it is, it tries to start the job if it has not yet been started.
  If the job has run before it will send the last value back right away.
  """
  def join("data_source:" <> name, _payload, socket) do
    case Loon.Scheduler.job_available?(name) do
      true ->
        Loon.Scheduler.invoke_job(name)
        {:ok, socket}

      false ->
        {:error, %{reason: "Data source does not exist"}}
    end
  end

  @doc """
  Callback when a socket disconnects. If the disconnecting socket
  is the last socket, it stops the job
  """
  def terminate(_reason, socket) do
    if LoonWeb.UserSocket.last_user?(socket.topic) do
      "data_source:" <> topic = socket.topic
      Loon.Scheduler.shutdown_job(topic)
    end

    :ok
  end
end
