defmodule Loon.Scheduler do
  @moduledoc """
  Main schedule handler for Quantum
  """
  use Quantum.Scheduler,
    otp_app: :loon

  @doc """
  Returns a map of available jobs in the `Loon.Jobs` namespace
  """
  def available_jobs do
    with {:ok, list} <- :application.get_key(:loon, :modules) do
      list
      |> Enum.map(&Module.split/1)
      |> Enum.filter(&match?(["Loon", "Jobs", _], &1))
      |> Enum.map(&Module.concat/1)
      |> Enum.reduce(%{}, fn module, acc ->
        acc
        |> Map.put(
          apply(module, :stringified_name, []),
          apply(module, :data, [])
        )
      end)
    end
  end

  @doc """
  Gets details for a specific job based on a name
  """
  def get_job(name), do: available_jobs() |> Map.get(name)

  @doc """
  Starts a Job based on a name. If the job already exists, does nothing
  """
  def invoke_job(name) do
    job = get_job(name)

    case(find_job(job[:name])) do
      nil ->
        apply(job[:module], :start, [])

      _ ->
        :ok
    end
  end

  @doc """
  Checks if a job is available to be run in the system
  """
  def job_available?(name), do: Map.has_key?(available_jobs(), name)

  @doc """
  Invokes the job once, to be run out of schedule
  """
  def run_once({module, function, args}), do: apply(module, function, args)

  @doc """
  Shuts down a running job
  """
  def shutdown_job(name) do
    name =
      name
      |> String.to_atom()

    delete_job(name)
  end

  @doc """
  Starts a job on a schedule and runs it once
  """
  def start_job(name, schedule, job) do
    new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_schedule(Quantum.Normalizer.normalize_schedule(schedule))
    |> Quantum.Job.set_task(job)
    |> add_job()

    run_once(job)
  end
end
