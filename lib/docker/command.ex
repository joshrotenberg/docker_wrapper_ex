defmodule Docker.Command do
  @moduledoc """
  Behaviour and runner for Docker commands.

  Modules implementing this behaviour define how to build argument lists
  for a specific Docker subcommand and how to parse the resulting output.
  """

  alias Docker.Config

  @doc """
  Returns the argument list for this command.
  """
  @callback args(command :: struct()) :: [String.t()]

  @doc """
  Parses the stdout and exit code from the Docker process into a result.
  """
  @callback parse_output(stdout :: String.t(), exit_code :: non_neg_integer()) ::
              {:ok, term()} | {:error, term()}

  @doc """
  Runs a Docker command.

  Takes a module implementing the `Docker.Command` behaviour, a command
  struct, and a `Docker.Config`. Builds the full argument list, executes
  Docker via `System.cmd/3`, and delegates parsing to the command module.

  ## Options

    * `:stream` - a function that receives each line of output as it's
      produced. When set, uses a Port for execution instead of `System.cmd`.
      The final result is still returned after the command completes.

  Emits `:telemetry` events for observability:

    * `[:docker_wrapper, :command, :start]` -- before execution
    * `[:docker_wrapper, :command, :stop]` -- after execution

  If the command exceeds the configured timeout, returns `{:error, :timeout}`.
  """
  @spec run(module(), struct(), Config.t(), keyword()) :: {:ok, term()} | {:error, term()}
  def run(mod, command, %Config{} = config, run_opts \\ []) do
    args = Config.base_args(config) ++ mod.args(command)
    stream_fn = Keyword.get(run_opts, :stream)

    :telemetry.execute(
      [:docker_wrapper, :command, :start],
      %{system_time: System.system_time()},
      %{command: mod, args: args}
    )

    result =
      if stream_fn do
        run_with_port(config, args, stream_fn, config.timeout)
      else
        run_with_cmd(config, args)
      end

    case result do
      {:ok, stdout, exit_code} ->
        :telemetry.execute(
          [:docker_wrapper, :command, :stop],
          %{system_time: System.system_time()},
          %{command: mod, args: args, exit_code: exit_code}
        )

        mod.parse_output(stdout, exit_code)

      {:error, _} = error ->
        error
    end
  end

  defp run_with_cmd(config, args) do
    opts = Config.cmd_opts(config)

    task =
      Task.async(fn ->
        System.cmd(config.binary, args, opts)
      end)

    case Task.yield(task, config.timeout) || Task.shutdown(task) do
      {:ok, {stdout, exit_code}} ->
        {:ok, stdout, exit_code}

      nil ->
        {:error, :timeout}
    end
  end

  defp run_with_port(config, args, stream_fn, timeout) do
    port =
      Port.open(
        {:spawn_executable, config.binary},
        [:binary, :exit_status, :stderr_to_stdout, args: args]
      )

    collect_port_output(port, stream_fn, "", timeout)
  end

  defp collect_port_output(port, stream_fn, acc, timeout) do
    receive do
      {^port, {:data, data}} ->
        {lines, remaining} = split_lines(acc <> data)
        Enum.each(lines, stream_fn)
        collect_port_output(port, stream_fn, remaining, timeout)

      {^port, {:exit_status, code}} ->
        if remaining_line?(acc), do: stream_fn.(acc)
        {:ok, "", code}
    after
      timeout ->
        Port.close(port)
        {:error, :timeout}
    end
  end

  defp split_lines(data) do
    parts = String.split(data, "\n")
    {Enum.slice(parts, 0..-2//1), List.last(parts)}
  end

  defp remaining_line?(buf), do: buf != ""

  @doc """
  Helper to add a flag to the arg list when a boolean is true.
  """
  @spec add_flag([String.t()], boolean(), String.t()) :: [String.t()]
  def add_flag(args, true, flag), do: args ++ [flag]
  def add_flag(args, _, _), do: args

  @doc """
  Helper to add an option with a value to the arg list when value is non-nil.
  """
  @spec add_opt([String.t()], term(), String.t()) :: [String.t()]
  def add_opt(args, nil, _), do: args
  def add_opt(args, val, flag), do: args ++ [flag, to_string(val)]

  @doc """
  Helper to add repeated options from a list, applying a formatting function.
  """
  @spec add_repeat([String.t()], list(), (term() -> [String.t()])) :: [String.t()]
  def add_repeat(args, [], _fun), do: args
  def add_repeat(args, items, fun), do: args ++ Enum.flat_map(items, fun)
end
