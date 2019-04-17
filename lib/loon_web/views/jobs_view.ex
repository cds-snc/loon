defmodule LoonWeb.JobsView do
  use LoonWeb, :view

  @doc """
  Renders a list of job data
  """
  def render("index.json", %{jobs: jobs}) do
    jobs
  end

  @doc """
  Renders data for a specific job
  """
  def render("show.json", %{data: data}) do
    data
  end
end
