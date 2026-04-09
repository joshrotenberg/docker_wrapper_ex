defmodule Docker.Commands.Volume.Ls do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker volume ls`.

  Uses `--format json` for machine-readable output.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          quiet: boolean(),
          filters: [String.t()]
        }

  defstruct quiet: false, filters: []

  def new, do: %__MODULE__{}

  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["volume", "ls", "--format", "json"]
    |> add_flag(cmd.quiet, "-q")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0) do
    volumes =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, volumes}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
