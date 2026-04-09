defmodule Docker.Commands.ContainerPrune do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker container prune`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_repeat: 3]

  @type t :: %__MODULE__{filters: [String.t()]}

  defstruct filters: []

  def new, do: %__MODULE__{}

  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["container", "prune", "-f"]
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
