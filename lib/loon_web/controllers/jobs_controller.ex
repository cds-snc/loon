defmodule LoonWeb.JobsController do
  use LoonWeb, :controller

  @doc """
  Returns a list of job data
  """
  def index(conn, _params) do
    render(conn, :index, jobs: Loon.Scheduler.available_jobs())
  end
end
