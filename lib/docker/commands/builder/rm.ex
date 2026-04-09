defmodule Docker.Commands.Builder.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx rm`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:name]
  defstruct [:name, force: false, all_inactive: false, keep_state: false]

  @type t :: %__MODULE__{}

  def new(name), do: %__MODULE__{name: name}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}
  def all_inactive(%__MODULE__{} = cmd), do: %{cmd | all_inactive: true}
  def keep_state(%__MODULE__{} = cmd), do: %{cmd | keep_state: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["buildx", "rm"]
    |> add_flag(cmd.force, "-f")
    |> add_flag(cmd.all_inactive, "--all-inactive")
    |> add_flag(cmd.keep_state, "--keep-state")
    |> Kernel.++([cmd.name])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
