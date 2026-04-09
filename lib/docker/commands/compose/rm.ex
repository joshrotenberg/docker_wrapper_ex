defmodule Docker.Commands.Compose.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose rm`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              force: false,
              stop: false,
              volumes: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}
  def stop(%__MODULE__{} = cmd), do: %{cmd | stop: true}
  def volumes(%__MODULE__{} = cmd), do: %{cmd | volumes: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["rm"])
    |> add_flag(cmd.force, "-f")
    |> add_flag(cmd.stop, "-s")
    |> add_flag(cmd.volumes, "-v")
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
