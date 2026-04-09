defmodule Docker.Commands.Compose.Images do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose images`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(services: [], quiet: false)

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["images", "--format", "json"])
    |> add_flag(cmd.quiet, "-q")
    |> Kernel.++(cmd.services)
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
