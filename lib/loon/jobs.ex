defmodule Loon.Jobs do
  @moduledoc """
  Module to provide all the base functionality of a Job
  """

  defmacro __using__(description: description, schedule: schedule) do
    quote do
      @doc """
      Returns a map of data around a Job
      """
      def data() do
        %{
          description: description(),
          module: __MODULE__,
          name: name(),
          schedule: schedule() |> normalize_schedule(),
          connected: LoonWeb.UserSocket.count_connections("data_source:" <> stringified_name()),
          last_sent: last_run(),
          json_data_url: "/" <> stringified_name()
        }
      end

      @doc """
      Returns the passed in description
      """
      def description(), do: unquote(description)

      @doc """
      Returns a atomized name of the job based on the module name inside the
      `Loon.Jobs` namespace.
      """
      def name() do
        __MODULE__
        |> Module.split()
        |> List.last()
        |> Macro.underscore()
        |> String.to_atom()
      end

      @doc """
      Main callback function to run a job. Handles inserting the data into the
      :ets cache and broadcasting the data to the channel.
      """
      def run do
        data = job()
        timestamp = Timex.now()

        :ets.insert(
          :job_state,
          {stringified_name(),
           %{
             data: data,
             timestamp: timestamp
           }}
        )

        LoonWeb.Endpoint.broadcast!("data_source:" <> stringified_name(), "data", %{
          data: data,
          timestamp: timestamp
        })
      end

      @doc """
      Returns the passed in schedule
      """
      def schedule, do: unquote(schedule)

      @doc """
      Main callback to start a job based on a name, schedule, and function
      """
      def start() do
        Loon.Scheduler.start_job(name(), unquote(schedule), {__MODULE__, :run, []})
      end

      @doc """
      Utility function to stringify name of Job from atom
      """
      def stringified_name(), do: name() |> Atom.to_string()

      @doc """
      Utility function to return the last run of the Job from the :ets
      cache.
      """
      def last_run() do
        name = stringified_name()

        case :ets.lookup(:job_state, name) do
          [{^name, data}] ->
            data[:timestamp]

          _ ->
            nil
        end
      end

      @doc """
      Normalizes the schedule input to a string for printing
      """
      def normalize_schedule(nil), do: nil

      def normalize_schedule(e) when is_binary(e),
        do: e |> String.downcase()

      def normalize_schedule({:cron, e}) when is_binary(e),
        do: e |> String.downcase()

      def normalize_schedule({:extended, e}) when is_binary(e),
        do: String.downcase(e) <> " * * * * *"
    end
  end
end
