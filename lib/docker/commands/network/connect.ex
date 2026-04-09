defmodule Docker.Commands.Network.Connect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker network connect`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          network: String.t(),
          container: String.t(),
          ip: String.t() | nil,
          ip6: String.t() | nil,
          aliases: [String.t()],
          links: [String.t()]
        }

  @enforce_keys [:network, :container]
  defstruct [:network, :container, :ip, :ip6, aliases: [], links: []]

  def new(network, container), do: %__MODULE__{network: network, container: container}

  def ip(%__MODULE__{} = cmd, addr), do: %{cmd | ip: addr}
  def ip6(%__MODULE__{} = cmd, addr), do: %{cmd | ip6: addr}
  def network_alias(%__MODULE__{} = cmd, a), do: %{cmd | aliases: cmd.aliases ++ [a]}
  def link(%__MODULE__{} = cmd, l), do: %{cmd | links: cmd.links ++ [l]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["network", "connect"]
    |> add_opt(cmd.ip, "--ip")
    |> add_opt(cmd.ip6, "--ip6")
    |> add_repeat(cmd.aliases, fn a -> ["--alias", a] end)
    |> add_repeat(cmd.links, fn l -> ["--link", l] end)
    |> Kernel.++([cmd.network, cmd.container])
  end

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
