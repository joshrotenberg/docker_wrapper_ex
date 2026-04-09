defmodule Docker.Commands.Network.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker network create`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          name: String.t(),
          driver: String.t() | nil,
          subnet: String.t() | nil,
          gateway: String.t() | nil,
          ip_range: String.t() | nil,
          internal: boolean(),
          attachable: boolean(),
          labels: [{String.t(), String.t()}],
          opts: [{String.t(), String.t()}]
        }

  @enforce_keys [:name]
  defstruct [
    :name,
    :driver,
    :subnet,
    :gateway,
    :ip_range,
    internal: false,
    attachable: false,
    labels: [],
    opts: []
  ]

  def new(name), do: %__MODULE__{name: name}

  def driver(%__MODULE__{} = cmd, d), do: %{cmd | driver: d}
  def subnet(%__MODULE__{} = cmd, s), do: %{cmd | subnet: s}
  def gateway(%__MODULE__{} = cmd, g), do: %{cmd | gateway: g}
  def ip_range(%__MODULE__{} = cmd, r), do: %{cmd | ip_range: r}
  def internal(%__MODULE__{} = cmd), do: %{cmd | internal: true}
  def attachable(%__MODULE__{} = cmd), do: %{cmd | attachable: true}

  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  def opt(%__MODULE__{} = cmd, key, value) do
    %{cmd | opts: cmd.opts ++ [{to_string(key), to_string(value)}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["network", "create"]
    |> add_opt(cmd.driver, "--driver")
    |> add_opt(cmd.subnet, "--subnet")
    |> add_opt(cmd.gateway, "--gateway")
    |> add_opt(cmd.ip_range, "--ip-range")
    |> add_flag(cmd.internal, "--internal")
    |> add_flag(cmd.attachable, "--attachable")
    |> add_repeat(cmd.labels, fn {k, v} -> ["--label", "#{k}=#{v}"] end)
    |> add_repeat(cmd.opts, fn {k, v} -> ["-o", "#{k}=#{v}"] end)
    |> Kernel.++([cmd.name])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
