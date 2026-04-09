defmodule Docker.Commands.Start do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker start`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          containers: [String.t()],
          attach: boolean(),
          interactive: boolean()
        }

  @enforce_keys [:containers]
  defstruct [
    :containers,
    attach: false,
    interactive: false
  ]

  def new(container) when is_binary(container), do: %__MODULE__{containers: [container]}
  def new(containers) when is_list(containers), do: %__MODULE__{containers: containers}

  def attach(%__MODULE__{} = cmd), do: %{cmd | attach: true}
  def interactive(%__MODULE__{} = cmd), do: %{cmd | interactive: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["start"]
    |> add_flag(cmd.attach, "-a")
    |> add_flag(cmd.interactive, "-i")
    |> Kernel.++(cmd.containers)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
