defmodule Docker.Commands.Builder.Prune do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker builder prune`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  defstruct all: false, keep_storage: nil, filters: []

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def all(%__MODULE__{} = cmd), do: %{cmd | all: true}
  def keep_storage(%__MODULE__{} = cmd, s), do: %{cmd | keep_storage: s}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["builder", "prune", "-f"]
    |> add_flag(cmd.all, "-a")
    |> add_opt(cmd.keep_storage, "--keep-storage")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
