defmodule Docker.Commands.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker rm`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          containers: [String.t()],
          force: boolean(),
          volumes: boolean()
        }

  @enforce_keys [:containers]
  defstruct [:containers, force: false, volumes: false]

  def new(container) when is_binary(container), do: %__MODULE__{containers: [container]}
  def new(containers) when is_list(containers), do: %__MODULE__{containers: containers}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}
  def volumes(%__MODULE__{} = cmd), do: %{cmd | volumes: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["rm"]
    |> add_flag(cmd.force, "-f")
    |> add_flag(cmd.volumes, "-v")
    |> Kernel.++(cmd.containers)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
