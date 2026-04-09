defmodule Docker.Commands.Builder.Use do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx use`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:name]
  defstruct [:name, default: false, global: false]

  @type t :: %__MODULE__{}

  def new(name), do: %__MODULE__{name: name}

  def default(%__MODULE__{} = cmd), do: %{cmd | default: true}
  def global(%__MODULE__{} = cmd), do: %{cmd | global: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["buildx", "use"]
    |> add_flag(cmd.default, "--default")
    |> add_flag(cmd.global, "--global")
    |> Kernel.++([cmd.name])
  end

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
