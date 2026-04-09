defmodule Docker.Commands.Context.Ls do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker context ls`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  defstruct quiet: false

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["context", "ls", "--format", "json"]
    |> add_flag(cmd.quiet, "-q")
  end

  @impl true
  def parse_output(stdout, 0) do
    contexts =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, contexts}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
