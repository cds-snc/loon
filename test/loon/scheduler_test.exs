defmodule Loon.SchedulerTest do
  use ExUnit.Case

  import Loon.Scheduler

  test "available_jobs/0 returns a map of available jobs in the `Loon.Jobs` namespace" do
    assert Map.has_key?(available_jobs(), "test")
  end

  test "get_job/1 returns data for one specific jon" do
    assert match?(
             %{
               connected: 0,
               description: "A test job that returns ok",
               last_sent: _timestamp,
               module: Loon.Jobs.Test,
               name: :test,
               schedule: "*/10 * * * * *"
             },
             get_job("test")
           )
  end

  test "invoke_job/1 starts a job if it has not been started" do
    assert invoke_job("test") == :ok
  end

  test "invoke_job/1 does not start a job if it is already running" do
    Loon.Jobs.Test.start()
    assert invoke_job("test") == :ok
  end

  test "job_available?/1 returns true if the job exists" do
    assert job_available?("test")
  end

  test "job_available?/1 returns false if the job does not exist" do
    refute job_available?("bad")
  end

  test "run_once/1 invokes a job once" do
    assert run_once({Loon.Jobs.Test, :run, []}) == :ok
  end

  test "shutdown_job/1 deletes an existing job" do
    Loon.Jobs.Test.start()
    shutdown_job("test")
    assert Loon.Scheduler.find_job(:test) == nil
    Loon.Jobs.Test.start()
  end

  test "start_job/3 starts a job with a name and schedule" do
    start_job(:fizzbizz, "* * * * *", {Loon.Jobs.Test, :run, []})
    assert Loon.Scheduler.find_job(:fizzbizz)
  end

  test "start_job/3 runs a job once" do
    assert start_job(:fizzbizz, "* * * * *", {Loon.Jobs.Test, :run, []}) == :ok
  end
end
