defmodule Docker.Commands.System.Prune do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker system prune`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]

  defstruct all: false, volumes: false, filters: []

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def all(%__MODULE__{} = cmd), do: %{cmd | all: true}
  def volumes(%__MODULE__{} = cmd), do: %{cmd | volumes: true}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["system", "prune", "-f"]
    |> add_flag(cmd.all, "-a")
    |> add_flag(cmd.volumes, "--volumes")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
