defmodule Docker.Commands.Network.Disconnect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker network disconnect`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          network: String.t(),
          container: String.t(),
          force: boolean()
        }

  @enforce_keys [:network, :container]
  defstruct [:network, :container, force: false]

  def new(network, container), do: %__MODULE__{network: network, container: container}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["network", "disconnect"]
    |> add_flag(cmd.force, "-f")
    |> Kernel.++([cmd.network, cmd.container])
  end

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
