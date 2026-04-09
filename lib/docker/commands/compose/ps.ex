defmodule Docker.Commands.Compose.Ps do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose ps`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              all: false,
              quiet: false,
              status: [],
              orphans: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def all(%__MODULE__{} = cmd), do: %{cmd | all: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def orphans(%__MODULE__{} = cmd), do: %{cmd | orphans: true}
  def filter_status(%__MODULE__{} = cmd, s), do: %{cmd | status: cmd.status ++ [s]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["ps", "--format", "json"])
    |> add_flag(cmd.all, "-a")
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.orphans, "--orphans")
    |> add_repeat(cmd.status, fn s -> ["--status", s] end)
    |> Kernel.++(cmd.services)
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
