defmodule Docker.Commands.Network.Ls do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker network ls`.

  Uses `--format json` for machine-readable output.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          quiet: boolean(),
          no_trunc: boolean(),
          filters: [String.t()]
        }

  defstruct quiet: false, no_trunc: false, filters: []

  def new, do: %__MODULE__{}

  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def no_trunc(%__MODULE__{} = cmd), do: %{cmd | no_trunc: true}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["network", "ls", "--format", "json"]
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.no_trunc, "--no-trunc")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0) do
    networks =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, networks}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
