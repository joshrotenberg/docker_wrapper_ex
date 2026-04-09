defmodule Docker.Commands.Network.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker network rm`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          networks: [String.t()],
          force: boolean()
        }

  @enforce_keys [:networks]
  defstruct [:networks, force: false]

  def new(network) when is_binary(network), do: %__MODULE__{networks: [network]}
  def new(networks) when is_list(networks), do: %__MODULE__{networks: networks}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["network", "rm"]
    |> add_flag(cmd.force, "-f")
    |> Kernel.++(cmd.networks)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
