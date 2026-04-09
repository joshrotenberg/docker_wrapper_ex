defmodule Docker.Commands.Swarm.Join do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm join`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @enforce_keys [:remote_addr]
  defstruct [:remote_addr, :token, :advertise_addr, :listen_addr, :data_path_addr]

  @type t :: %__MODULE__{}

  def new(remote_addr), do: %__MODULE__{remote_addr: remote_addr}

  def token(%__MODULE__{} = cmd, t), do: %{cmd | token: t}
  def advertise_addr(%__MODULE__{} = cmd, a), do: %{cmd | advertise_addr: a}
  def listen_addr(%__MODULE__{} = cmd, l), do: %{cmd | listen_addr: l}
  def data_path_addr(%__MODULE__{} = cmd, d), do: %{cmd | data_path_addr: d}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "join"]
    |> add_opt(cmd.token, "--token")
    |> add_opt(cmd.advertise_addr, "--advertise-addr")
    |> add_opt(cmd.listen_addr, "--listen-addr")
    |> add_opt(cmd.data_path_addr, "--data-path-addr")
    |> Kernel.++([cmd.remote_addr])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
