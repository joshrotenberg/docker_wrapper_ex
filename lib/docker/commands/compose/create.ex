defmodule Docker.Commands.Compose.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose create`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              build_flag: false,
              force_recreate: false,
              no_recreate: false,
              no_build: false,
              pull: false,
              remove_orphans: false,
              scale: []
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def build(%__MODULE__{} = cmd), do: %{cmd | build_flag: true}
  def force_recreate(%__MODULE__{} = cmd), do: %{cmd | force_recreate: true}
  def no_recreate(%__MODULE__{} = cmd), do: %{cmd | no_recreate: true}
  def no_build(%__MODULE__{} = cmd), do: %{cmd | no_build: true}
  def pull(%__MODULE__{} = cmd), do: %{cmd | pull: true}
  def remove_orphans(%__MODULE__{} = cmd), do: %{cmd | remove_orphans: true}

  def scale(%__MODULE__{} = cmd, service, count) do
    %{cmd | scale: cmd.scale ++ [{service, count}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["create"])
    |> add_flag(cmd.build_flag, "--build")
    |> add_flag(cmd.force_recreate, "--force-recreate")
    |> add_flag(cmd.no_recreate, "--no-recreate")
    |> add_flag(cmd.no_build, "--no-build")
    |> add_flag(cmd.pull, "--pull")
    |> add_flag(cmd.remove_orphans, "--remove-orphans")
    |> add_repeat(cmd.scale, fn {s, c} -> ["--scale", "#{s}=#{c}"] end)
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
