defmodule Docker.Commands.History do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker history`.

  Uses `--format json` for machine-readable output.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          image: String.t(),
          quiet: boolean(),
          no_trunc: boolean()
        }

  @enforce_keys [:image]
  defstruct [:image, quiet: false, no_trunc: false]

  def new(image), do: %__MODULE__{image: image}

  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def no_trunc(%__MODULE__{} = cmd), do: %{cmd | no_trunc: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["history", "--format", "json"]
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.no_trunc, "--no-trunc")
    |> Kernel.++([cmd.image])
  end

  @impl true
  def parse_output(stdout, 0) do
    layers =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, layers}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
