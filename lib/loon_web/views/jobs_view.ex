defmodule LoonWeb.JobsView do
  use LoonWeb, :view

  @doc """
  Renders a list of job data
  """
  def render("index.json", %{jobs: jobs}) do
    jobs
  end
end
