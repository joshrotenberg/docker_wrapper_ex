defmodule Docker.Commands.Volume.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker volume rm`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          volumes: [String.t()],
          force: boolean()
        }

  @enforce_keys [:volumes]
  defstruct [:volumes, force: false]

  def new(volume) when is_binary(volume), do: %__MODULE__{volumes: [volume]}
  def new(volumes) when is_list(volumes), do: %__MODULE__{volumes: volumes}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["volume", "rm"]
    |> add_flag(cmd.force, "-f")
    |> Kernel.++(cmd.volumes)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
