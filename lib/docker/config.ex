defmodule Docker.Config do
  @moduledoc """
  Configuration for the Docker CLI wrapper.

  Holds the path to the Docker binary, working directory, environment
  variables, and timeout settings used when executing Docker commands.
  """

  @default_timeout 30_000

  @type runner :: :system | :forcola

  @type t :: %__MODULE__{
          binary: String.t(),
          working_dir: String.t() | nil,
          env: [{String.t(), String.t()}],
          timeout: pos_integer(),
          runner: runner()
        }

  @enforce_keys [:binary]
  defstruct [:binary, :working_dir, env: [], timeout: @default_timeout, runner: :system]

  @doc """
  Creates a new `Docker.Config` struct.

  ## Options

    * `:binary` - path to the Docker executable (default: auto-detected)
    * `:working_dir` - working directory for commands (default: `nil`, uses current directory)
    * `:env` - list of `{key, value}` tuples for environment variables (default: `[]`)
    * `:timeout` - command timeout in milliseconds (default: `#{@default_timeout}`)
    * `:runner` - execution backend, `:system` or `:forcola` (default: `:system`)

  The `:forcola` runner routes buffered commands through the optional
  [forcola](https://hex.pm/packages/forcola) library, which places each child
  in its own process group and group-kills it (SIGTERM then SIGKILL) on timeout
  or when the BEAM dies, preventing leaked `docker` CLI processes. It requires
  the `:forcola` dependency and a POSIX platform; when forcola is not loaded the
  runner transparently falls back to `:system`.

  ## Examples

      iex> config = Docker.Config.new()
      iex> config.binary != nil
      true

      iex> config = Docker.Config.new(timeout: 60_000)
      iex> config.timeout
      60_000

      iex> config = Docker.Config.new(runner: :forcola)
      iex> config.runner
      :forcola

  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    %__MODULE__{
      binary: Keyword.get(opts, :binary, find_binary()),
      working_dir: Keyword.get(opts, :working_dir),
      env: Keyword.get(opts, :env, []),
      timeout: Keyword.get(opts, :timeout, @default_timeout),
      runner: Keyword.get(opts, :runner, :system)
    }
  end

  @doc """
  Returns base arguments prepended to all Docker commands.
  """
  @spec base_args(t()) :: [String.t()]
  def base_args(%__MODULE__{}), do: []

  @doc """
  Builds the options keyword list for `System.cmd/3`.
  """
  @spec cmd_opts(t()) :: keyword()
  def cmd_opts(%__MODULE__{} = config) do
    opts = [stderr_to_stdout: true]

    opts =
      if config.working_dir do
        Keyword.put(opts, :cd, config.working_dir)
      else
        opts
      end

    if config.env != [] do
      Keyword.put(opts, :env, config.env)
    else
      opts
    end
  end

  @doc """
  Finds the Docker-compatible binary on the system.

  Checks the `DOCKER_PATH` environment variable first, then searches
  for `docker`, `podman`, or `nerdctl` on the PATH.

  Raises if no binary is found.
  """
  @spec find_binary() :: String.t()
  def find_binary do
    case System.get_env("DOCKER_PATH") do
      nil ->
        Enum.find_value(["docker", "podman", "nerdctl"], fn bin ->
          System.find_executable(bin)
        end) || raise "no Docker-compatible binary found on PATH"

      path ->
        path
    end
  end
end
