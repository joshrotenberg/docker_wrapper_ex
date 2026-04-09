defmodule Docker.Commands.Compose.Start do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose start`.
  """

  @behaviour Docker.Command
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(services: [])

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd) ++ ["start"] ++ cmd.services
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
