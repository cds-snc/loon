defmodule LoonWeb.JobsController do
  use LoonWeb, :controller

  @doc """
  Returns a list of job data
  """
  def index(conn, _params) do
    render(conn, :index, jobs: Loon.Scheduler.available_jobs())
  end

  @doc """
  Return the current data for that specific job
  """
  def show(conn, %{"id" => name}) do
    case Loon.Scheduler.get_job(name) do
      %{module: _module} = job -> render(conn, :show, data: apply(job[:module], :job, []))
      _ -> render(conn, :show, data: %{})
    end
  end
end
