defmodule Docker.Commands.Compose.Pull do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose pull`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              quiet: false,
              ignore_pull_failures: false,
              include_deps: false,
              no_parallel: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def ignore_pull_failures(%__MODULE__{} = cmd), do: %{cmd | ignore_pull_failures: true}
  def include_deps(%__MODULE__{} = cmd), do: %{cmd | include_deps: true}
  def no_parallel(%__MODULE__{} = cmd), do: %{cmd | no_parallel: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["pull"])
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.ignore_pull_failures, "--ignore-pull-failures")
    |> add_flag(cmd.include_deps, "--include-deps")
    |> add_flag(cmd.no_parallel, "--no-parallel")
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
