defmodule Docker.Commands.Swarm.Init do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm init`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  defstruct [
    :advertise_addr,
    :listen_addr,
    :data_path_addr,
    :data_path_port,
    :default_addr_pool,
    :force_new_cluster,
    autolock: false
  ]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def advertise_addr(%__MODULE__{} = cmd, a), do: %{cmd | advertise_addr: a}
  def listen_addr(%__MODULE__{} = cmd, l), do: %{cmd | listen_addr: l}
  def data_path_addr(%__MODULE__{} = cmd, d), do: %{cmd | data_path_addr: d}
  def data_path_port(%__MODULE__{} = cmd, p), do: %{cmd | data_path_port: to_string(p)}
  def force_new_cluster(%__MODULE__{} = cmd), do: %{cmd | force_new_cluster: true}
  def autolock(%__MODULE__{} = cmd), do: %{cmd | autolock: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "init"]
    |> add_opt(cmd.advertise_addr, "--advertise-addr")
    |> add_opt(cmd.listen_addr, "--listen-addr")
    |> add_opt(cmd.data_path_addr, "--data-path-addr")
    |> add_opt(cmd.data_path_port, "--data-path-port")
    |> add_flag(cmd.force_new_cluster, "--force-new-cluster")
    |> add_flag(cmd.autolock, "--autolock")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
