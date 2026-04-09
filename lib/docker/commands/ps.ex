defmodule Docker.Commands.Ps do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker ps`.

  Uses `--format json` for machine-readable output parsed into maps.

  ## Examples

      import Docker.Commands.Ps

      new()
      |> all()
      |> filter("name=my-nginx")
      |> Docker.ps()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          all: boolean(),
          quiet: boolean(),
          latest: boolean(),
          last: non_neg_integer() | nil,
          size: boolean(),
          filters: [String.t()]
        }

  defstruct all: false,
            quiet: false,
            latest: false,
            last: nil,
            size: false,
            filters: []

  def new, do: %__MODULE__{}

  def all(%__MODULE__{} = cmd), do: %{cmd | all: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def latest(%__MODULE__{} = cmd), do: %{cmd | latest: true}
  def last(%__MODULE__{} = cmd, n), do: %{cmd | last: n}
  def size(%__MODULE__{} = cmd), do: %{cmd | size: true}

  def filter(%__MODULE__{} = cmd, f) do
    %{cmd | filters: cmd.filters ++ [f]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["ps", "--format", "json"]
      |> add_flag(cmd.all, "-a")
      |> add_flag(cmd.quiet, "-q")
      |> add_flag(cmd.latest, "-l")
      |> add_flag(cmd.size, "-s")
      |> add_opt(cmd.last && to_string(cmd.last), "-n")
      |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)

    base
  end

  @impl true
  def parse_output(stdout, 0) do
    containers =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, containers}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
