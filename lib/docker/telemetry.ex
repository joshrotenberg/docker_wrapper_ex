defmodule Docker.Telemetry do
  @moduledoc """
  Telemetry event definitions for docker_wrapper.

  ## Events

  All events are prefixed with `[:docker_wrapper]`.

  ### Command execution

    * `[:docker_wrapper, :command, :start]` -- emitted before a command runs

      Measurements: `%{system_time: integer()}`

      Metadata: `%{command: module(), args: [String.t()]}`

    * `[:docker_wrapper, :command, :stop]` -- emitted after a command completes

      Measurements: `%{system_time: integer()}`

      Metadata: `%{command: module(), args: [String.t()], exit_code: non_neg_integer()}`

  ## Attaching handlers

      :telemetry.attach(
        "docker-logger",
        [:docker_wrapper, :command, :stop],
        fn event, measurements, metadata, _config ->
          Logger.info("Docker [\#{inspect(metadata.command)}] exited \#{metadata.exit_code}")
        end,
        nil
      )

  """

  @doc """
  Returns a list of all telemetry events emitted by this library.
  """
  @spec events() :: [list(atom())]
  def events do
    [
      [:docker_wrapper, :command, :start],
      [:docker_wrapper, :command, :stop]
    ]
  end
end
