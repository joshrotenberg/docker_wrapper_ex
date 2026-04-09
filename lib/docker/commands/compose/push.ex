defmodule Docker.Commands.Compose.Push do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose push`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              ignore_push_failures: false,
              quiet: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def ignore_push_failures(%__MODULE__{} = cmd), do: %{cmd | ignore_push_failures: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["push"])
    |> add_flag(cmd.ignore_push_failures, "--ignore-push-failures")
    |> add_flag(cmd.quiet, "-q")
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
