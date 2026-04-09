defmodule Docker.Commands.ImagePrune do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker image prune`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          all: boolean(),
          filters: [String.t()]
        }

  defstruct all: false, filters: []

  def new, do: %__MODULE__{}

  def all(%__MODULE__{} = cmd), do: %{cmd | all: true}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["image", "prune", "-f"]
    |> add_flag(cmd.all, "-a")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
