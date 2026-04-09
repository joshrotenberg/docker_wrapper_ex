defmodule Docker.Commands.Compose.Down do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose down`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              volumes: false,
              rmi: nil,
              remove_orphans: false,
              timeout: nil
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def project_directory(%__MODULE__{} = cmd, d), do: %{cmd | project_directory: d}
  def env_file(%__MODULE__{} = cmd, f), do: %{cmd | env_files: cmd.env_files ++ [f]}
  def profile(%__MODULE__{} = cmd, p), do: %{cmd | profiles: cmd.profiles ++ [p]}
  def volumes(%__MODULE__{} = cmd), do: %{cmd | volumes: true}
  def rmi(%__MODULE__{} = cmd, type), do: %{cmd | rmi: type}
  def remove_orphans(%__MODULE__{} = cmd), do: %{cmd | remove_orphans: true}
  def timeout(%__MODULE__{} = cmd, t), do: %{cmd | timeout: t}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["down"])
    |> add_flag(cmd.volumes, "-v")
    |> add_flag(cmd.remove_orphans, "--remove-orphans")
    |> add_opt(cmd.rmi, "--rmi")
    |> add_opt(cmd.timeout && to_string(cmd.timeout), "-t")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
