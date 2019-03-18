defmodule Loon.Application do
  @moduledoc false

  use Application

  @doc """
  Starts the main application including the Phoenix endpoint
  and the Quantum scheduler
  """
  def start(_type, _args) do
    children = [
      LoonWeb.Endpoint,
      Loon.Scheduler
    ]

    :ets.new(:job_state, [:set, :public, :named_table])

    opts = [strategy: :one_for_one, name: Loon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LoonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
