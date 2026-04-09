defmodule Docker.Supervised do
  @moduledoc """
  A GenServer wrapping the full container lifecycle under OTP supervision.

  This is a BEAM-native extension not present in the Rust crate. It starts
  a Docker container in detached mode, monitors its health, and cleans up
  on termination.

  ## Examples

      # Start a supervised Redis container
      {:ok, pid} = Docker.Supervised.start_link(
        Docker.Commands.Run.new("redis:7")
        |> Docker.Commands.Run.name("my-redis")
        |> Docker.Commands.Run.port(6379, 6379),
        health_interval: 5_000,
        rm_on_terminate: true
      )

      Docker.Supervised.container_id(pid)  #=> "abc123..."
      Docker.Supervised.status(pid)        #=> :running
      Docker.Supervised.healthy?(pid)      #=> :healthy

      # Under a supervisor
      children = [
        {Docker.Supervised, {run_cmd, name: MyApp.Redis, health_interval: 3_000}}
      ]
      Supervisor.start_link(children, strategy: :one_for_one)

  ## Options

    * `:name` - GenServer registration name
    * `:health_check` - whether to poll container health (default: `true`)
    * `:health_interval` - milliseconds between health checks (default: `5_000`)
    * `:rm_on_terminate` - force-remove container on GenServer terminate (default: `false`)
    * `:config` - `Docker.Config` to use for all commands (default: `Docker.Config.new()`)

  """

  use GenServer

  alias Docker.Commands

  defstruct [:run_cmd, :container_id, :status, :health, :opts, :config]

  @type t :: %__MODULE__{
          run_cmd: Commands.Run.t(),
          container_id: String.t() | nil,
          status: :running | :stopped | :failed,
          health: :starting | :healthy | :unhealthy | :unknown | :not_found,
          opts: keyword(),
          config: Docker.Config.t()
        }

  # -- Client API --

  @doc """
  Starts a supervised container.

  Accepts a `Docker.Commands.Run` struct and options. The container is
  automatically started in detached mode.
  """
  @spec start_link(Commands.Run.t(), keyword()) :: GenServer.on_start()
  def start_link(%Commands.Run{} = run_cmd, opts \\ []) do
    {gen_opts, opts} = Keyword.split(opts, [:name])
    GenServer.start_link(__MODULE__, {run_cmd, opts}, gen_opts)
  end

  @doc "Returns the container ID."
  @spec container_id(GenServer.server()) :: String.t() | nil
  def container_id(pid), do: GenServer.call(pid, :container_id)

  @doc "Returns the container status."
  @spec status(GenServer.server()) :: :running | :stopped | :failed
  def status(pid), do: GenServer.call(pid, :status)

  @doc "Returns the container health status."
  @spec healthy?(GenServer.server()) :: atom()
  def healthy?(pid), do: GenServer.call(pid, :healthy?)

  @doc "Stops the container gracefully."
  @spec stop_container(GenServer.server(), timeout()) :: :ok
  def stop_container(pid, timeout \\ 30_000) do
    GenServer.call(pid, :stop_container, timeout)
  end

  @doc """
  Returns a child spec for use in supervisors.

  Expects `{run_cmd, opts}` as the argument.
  """
  def child_spec({%Commands.Run{} = run_cmd, opts}) do
    name = Keyword.get(opts, :name)

    %{
      id: name || __MODULE__,
      start: {__MODULE__, :start_link, [run_cmd, opts]},
      restart: :transient,
      shutdown: 30_000
    }
  end

  # -- Server Callbacks --

  @impl true
  def init({run_cmd, opts}) do
    config = Keyword.get(opts, :config, Docker.Config.new())
    run_cmd = Commands.Run.detach(run_cmd)

    case Docker.Command.run(Commands.Run, run_cmd, config) do
      {:ok, %Docker.ContainerId{full: container_id}} ->
        health_interval = Keyword.get(opts, :health_interval, 5_000)

        if Keyword.get(opts, :health_check, true) do
          Process.send_after(self(), :health_check, health_interval)
        end

        {:ok,
         %__MODULE__{
           run_cmd: run_cmd,
           container_id: container_id,
           status: :running,
           health: :starting,
           opts: opts,
           config: config
         }}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:container_id, _from, state) do
    {:reply, state.container_id, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:healthy?, _from, state) do
    {:reply, state.health, state}
  end

  def handle_call(:stop_container, _from, state) do
    stop_cmd = Commands.Stop.new(state.container_id)
    Docker.Command.run(Commands.Stop, stop_cmd, state.config)
    {:reply, :ok, %{state | status: :stopped}}
  end

  @impl true
  def handle_info(:health_check, state) do
    health_interval = Keyword.get(state.opts, :health_interval, 5_000)
    new_health = check_container_health(state.container_id, state.config)

    if new_health not in [:not_found, :stopped] do
      Process.send_after(self(), :health_check, health_interval)
    end

    {:noreply, %{state | health: new_health}}
  end

  @impl true
  def terminate(_reason, %{container_id: id, status: :running} = state) when id != nil do
    stop_cmd = Commands.Stop.new(id)
    Docker.Command.run(Commands.Stop, stop_cmd, state.config)

    if Keyword.get(state.opts, :rm_on_terminate, false) do
      rm_cmd = Commands.Rm.new(id) |> Commands.Rm.force()
      Docker.Command.run(Commands.Rm, rm_cmd, state.config)
    end

    :ok
  end

  def terminate(_, _), do: :ok

  # -- Private --

  defp check_container_health(container_id, config) do
    inspect_cmd = Commands.Inspect.new(container_id)

    case Docker.Command.run(Commands.Inspect, inspect_cmd, config) do
      {:ok, [%{"State" => %{"Status" => "running", "Health" => %{"Status" => health}}}]} ->
        health_atom(health)

      {:ok, [%{"State" => %{"Status" => "running"}}]} ->
        :healthy

      {:ok, [%{"State" => %{"Status" => "exited"}}]} ->
        :stopped

      {:ok, [%{"State" => %{"Status" => status}}]} ->
        {:unhealthy, status}

      {:ok, []} ->
        :not_found

      {:error, _} ->
        :unknown
    end
  end

  defp health_atom("healthy"), do: :healthy
  defp health_atom("starting"), do: :starting
  defp health_atom("unhealthy"), do: :unhealthy
  defp health_atom(other), do: {:unhealthy, other}
end
