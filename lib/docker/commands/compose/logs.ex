defmodule Docker.Commands.Compose.Logs do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose logs`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              follow: false,
              timestamps: false,
              tail: nil,
              since: nil,
              until_time: nil,
              no_color: false,
              no_log_prefix: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def follow(%__MODULE__{} = cmd), do: %{cmd | follow: true}
  def timestamps(%__MODULE__{} = cmd), do: %{cmd | timestamps: true}
  def tail(%__MODULE__{} = cmd, n), do: %{cmd | tail: to_string(n)}
  def since(%__MODULE__{} = cmd, s), do: %{cmd | since: s}
  def until_time(%__MODULE__{} = cmd, u), do: %{cmd | until_time: u}
  def no_color(%__MODULE__{} = cmd), do: %{cmd | no_color: true}
  def no_log_prefix(%__MODULE__{} = cmd), do: %{cmd | no_log_prefix: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["logs"])
    |> add_flag(cmd.follow, "-f")
    |> add_flag(cmd.timestamps, "-t")
    |> add_flag(cmd.no_color, "--no-color")
    |> add_flag(cmd.no_log_prefix, "--no-log-prefix")
    |> add_opt(cmd.tail, "--tail")
    |> add_opt(cmd.since, "--since")
    |> add_opt(cmd.until_time, "--until")
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
