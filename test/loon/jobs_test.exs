defmodule Loon.Jobs.JobTest do
  @moduledoc false

  use Loon.Jobs,
    description: "A test job that returns ok",
    schedule: {:extended, "*/10"}

  @doc """
  Returns ok
  """
  def job do
    "ok"
  end
end

defmodule Loon.JobsTest do
  use LoonWeb.ChannelCase

  import Loon.Jobs.JobTest

  test "data/0 returns a map of relevant data to the job" do
    assert match?(
             %{
               description: "A test job that returns ok",
               module: Loon.Jobs.JobTest,
               name: :job_test,
               schedule: "*/10 * * * * *",
               connected: _connected,
               last_sent: _timestamp
             },
             data()
           )
  end

  test "description/0 returns the description of the job" do
    assert "A test job that returns ok" == description()
  end

  test "name/0 returns the an atomized version of the last entry in the Jobs namespace" do
    assert :job_test == name()
  end

  test "run/0 executes the job, saves the data to an ets table and broadcasts the message to the channel" do
    LoonWeb.UserSocket
    |> socket
    |> subscribe_and_join(LoonWeb.DataSourceChannel, "data_source:job_test")

    result = run()
    assert result == :ok
    cached_data = :ets.lookup(:job_state, "job_test")
    assert [{"job_test", %{data: "ok", timestamp: _timestamp}}] = cached_data
    assert_broadcast "data", cached_data
  end

  test "schedule/0 returns the schedule for the job" do
    assert {:extended, "*/10"} == schedule()
  end

  test "start/0 starts the job in the scheduler" do
    start()

    assert match?(
             %Quantum.Job{
               name: :job_test,
               overlap: true,
               run_strategy: %Quantum.RunStrategy.Random{nodes: :cluster},
               schedule: _schedule,
               state: :active,
               task: {Loon.Jobs.JobTest, :run, []},
               timezone: :utc
             },
             Loon.Scheduler.find_job(:job_test)
           )
  end

  test "stringified_name/0 returns a string version of the job name" do
    assert "job_test" == stringified_name()
  end
end
