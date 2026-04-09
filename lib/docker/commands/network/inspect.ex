defmodule Docker.Commands.Network.Inspect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker network inspect`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @type t :: %__MODULE__{
          networks: [String.t()],
          format: String.t() | nil
        }

  @enforce_keys [:networks]
  defstruct [:networks, :format]

  def new(network) when is_binary(network), do: %__MODULE__{networks: [network]}
  def new(networks) when is_list(networks), do: %__MODULE__{networks: networks}

  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["network", "inspect"]
    |> add_opt(cmd.format, "--format")
    |> Kernel.++(cmd.networks)
  end

  @impl true
  def parse_output(stdout, 0) do
    case Jason.decode(stdout) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {:json_parse_error, reason}}
    end
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
