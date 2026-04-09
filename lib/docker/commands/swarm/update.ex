defmodule Docker.Commands.Swarm.Update do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm update`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  defstruct [:cert_expiry, :dispatcher_heartbeat, :task_history_limit, autolock: false]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def cert_expiry(%__MODULE__{} = cmd, c), do: %{cmd | cert_expiry: c}
  def dispatcher_heartbeat(%__MODULE__{} = cmd, d), do: %{cmd | dispatcher_heartbeat: d}
  def task_history_limit(%__MODULE__{} = cmd, t), do: %{cmd | task_history_limit: to_string(t)}
  def autolock(%__MODULE__{} = cmd), do: %{cmd | autolock: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "update"]
    |> add_opt(cmd.cert_expiry, "--cert-expiry")
    |> add_opt(cmd.dispatcher_heartbeat, "--dispatcher-heartbeat")
    |> add_opt(cmd.task_history_limit, "--task-history-limit")
    |> add_flag(cmd.autolock, "--autolock")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
