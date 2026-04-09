defmodule Docker.Stream do
  @moduledoc """
  Port-based streaming for long-running Docker commands.

  A BEAM-native extension not present in the Rust crate. Useful for
  `docker logs --follow`, `docker events`, `docker build`, etc.

  Lines are sent as messages to the subscriber process:

      {:docker_stream, pid, {:stdout, line}}
      {:docker_stream, pid, {:exit, exit_code}}

  ## Examples

      # Stream logs from a container
      {:ok, stream} = Docker.Stream.start_link(
        Docker.Commands.Logs.new("my-container") |> Docker.Commands.Logs.follow(),
        subscriber: self()
      )

      receive do
        {:docker_stream, ^stream, {:stdout, line}} ->
          IO.puts("LOG: \#{line}")
        {:docker_stream, ^stream, {:exit, 0}} ->
          IO.puts("Stream ended")
      end

      # Stop streaming
      Docker.Stream.stop(stream)

  ## Options

    * `:subscriber` - PID to receive stream messages (required)
    * `:config` - `Docker.Config` to use (default: `Docker.Config.new()`)

  """

  use GenServer

  @type stream_message ::
          {:docker_stream, pid(), {:stdout, String.t()}}
          | {:docker_stream, pid(), {:exit, non_neg_integer()}}

  defstruct [:port, :subscriber, :config, buffer: ""]

  # -- Client API --

  @doc """
  Starts a streaming process for the given command.
  """
  @spec start_link(struct(), keyword()) :: GenServer.on_start()
  def start_link(%module{} = cmd, opts) do
    GenServer.start_link(__MODULE__, {module, cmd, opts})
  end

  @doc """
  Stops the streaming process.
  """
  @spec stop(GenServer.server()) :: :ok
  def stop(pid), do: GenServer.stop(pid)

  # -- Server Callbacks --

  @impl true
  def init({module, cmd, opts}) do
    subscriber = Keyword.fetch!(opts, :subscriber)
    config = Keyword.get(opts, :config, Docker.Config.new())

    args = Docker.Config.base_args(config) ++ module.args(cmd)

    port =
      Port.open(
        {:spawn_executable, config.binary},
        [:binary, :exit_status, :stderr_to_stdout, args: args]
      )

    {:ok, %__MODULE__{port: port, subscriber: subscriber, config: config}}
  end

  @impl true
  def handle_info({port, {:data, data}}, %{port: port} = state) do
    {lines, remaining} = split_lines(state.buffer <> data)

    for line <- lines do
      send(state.subscriber, {:docker_stream, self(), {:stdout, line}})
    end

    {:noreply, %{state | buffer: remaining}}
  end

  def handle_info({port, {:exit_status, code}}, %{port: port} = state) do
    if state.buffer != "" do
      send(state.subscriber, {:docker_stream, self(), {:stdout, state.buffer}})
    end

    send(state.subscriber, {:docker_stream, self(), {:exit, code}})
    {:stop, :normal, state}
  end

  # -- Private --

  defp split_lines(data) do
    parts = String.split(data, "\n")
    lines = Enum.slice(parts, 0..-2//1)
    remaining = List.last(parts)
    {lines, remaining}
  end
end
