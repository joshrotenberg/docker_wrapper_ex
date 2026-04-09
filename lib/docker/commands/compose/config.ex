defmodule Docker.Commands.Compose.Config do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose config`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              quiet: false,
              resolve_image_digests: false,
              no_interpolate: false,
              no_normalize: false,
              services: false,
              volumes: false,
              format: nil
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def resolve_image_digests(%__MODULE__{} = cmd), do: %{cmd | resolve_image_digests: true}
  def no_interpolate(%__MODULE__{} = cmd), do: %{cmd | no_interpolate: true}
  def no_normalize(%__MODULE__{} = cmd), do: %{cmd | no_normalize: true}
  def services_only(%__MODULE__{} = cmd), do: %{cmd | services: true}
  def volumes_only(%__MODULE__{} = cmd), do: %{cmd | volumes: true}
  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["config"])
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.resolve_image_digests, "--resolve-image-digests")
    |> add_flag(cmd.no_interpolate, "--no-interpolate")
    |> add_flag(cmd.no_normalize, "--no-normalize")
    |> add_flag(cmd.services, "--services")
    |> add_flag(cmd.volumes, "--volumes")
    |> add_opt(cmd.format, "--format")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
