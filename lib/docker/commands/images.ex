defmodule Docker.Commands.Images do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker images`.

  Uses `--format json` for machine-readable output parsed into maps.

  ## Examples

      import Docker.Commands.Images

      new()
      |> filter("reference=nginx")
      |> Docker.images()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          repository: String.t() | nil,
          all: boolean(),
          quiet: boolean(),
          digests: boolean(),
          no_trunc: boolean(),
          filters: [String.t()]
        }

  defstruct repository: nil,
            all: false,
            quiet: false,
            digests: false,
            no_trunc: false,
            filters: []

  def new, do: %__MODULE__{}
  def new(repository), do: %__MODULE__{repository: repository}

  def all(%__MODULE__{} = cmd), do: %{cmd | all: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def digests(%__MODULE__{} = cmd), do: %{cmd | digests: true}
  def no_trunc(%__MODULE__{} = cmd), do: %{cmd | no_trunc: true}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["images", "--format", "json"]
      |> add_flag(cmd.all, "-a")
      |> add_flag(cmd.quiet, "-q")
      |> add_flag(cmd.digests, "--digests")
      |> add_flag(cmd.no_trunc, "--no-trunc")
      |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)

    if cmd.repository, do: base ++ [cmd.repository], else: base
  end

  @impl true
  def parse_output(stdout, 0) do
    images =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, images}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
