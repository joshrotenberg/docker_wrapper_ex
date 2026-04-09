defmodule Docker.Debug.Config do
  @moduledoc """
  Debug configuration for Docker command execution.

  Controls dry-run mode, verbose logging, and retry behavior.

  ## Examples

      # Dry run -- see what would be executed without running it
      debug = Docker.Debug.Config.new(dry_run: true)
      {:ok, cmd_string} = Docker.run(run_cmd, debug: debug)

      # Verbose logging
      debug = Docker.Debug.Config.new(verbose: true)

      # With retry
      debug = Docker.Debug.Config.new(retry: Docker.Debug.Retry.new(max_attempts: 5))

  """

  @type t :: %__MODULE__{
          dry_run: boolean(),
          verbose: boolean(),
          retry: Docker.Debug.Retry.t() | nil
        }

  defstruct dry_run: false,
            verbose: false,
            retry: nil

  @doc """
  Creates a new debug config.

  ## Options

    * `:dry_run` - build the command but don't execute it (default: false)
    * `:verbose` - log commands and output via Logger (default: false)
    * `:retry` - a `Docker.Debug.Retry` policy (default: nil)

  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end
end
