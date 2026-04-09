defmodule Docker.Commands.Compose.Restart do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose restart`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(services: [], timeout: nil)

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def timeout(%__MODULE__{} = cmd, t), do: %{cmd | timeout: t}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["restart"])
    |> add_opt(cmd.timeout && to_string(cmd.timeout), "-t")
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
