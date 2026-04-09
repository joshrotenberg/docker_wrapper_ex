defmodule Docker.Commands.Compose.Exec do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose exec`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              service: nil,
              command: [],
              detach: false,
              interactive: true,
              tty: true,
              privileged: false,
              user: nil,
              workdir: nil,
              env: [],
              index: nil
            )

  @type t :: %__MODULE__{}

  def new(service, command) when is_list(command) do
    %__MODULE__{service: service, command: command}
  end

  def new(service, command) when is_binary(command) do
    %__MODULE__{service: service, command: [command]}
  end

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def detach(%__MODULE__{} = cmd), do: %{cmd | detach: true}
  def no_tty(%__MODULE__{} = cmd), do: %{cmd | tty: false}
  def privileged(%__MODULE__{} = cmd), do: %{cmd | privileged: true}
  def user(%__MODULE__{} = cmd, u), do: %{cmd | user: u}
  def workdir(%__MODULE__{} = cmd, w), do: %{cmd | workdir: w}
  def index(%__MODULE__{} = cmd, i), do: %{cmd | index: i}

  def env(%__MODULE__{} = cmd, key, value) do
    %{cmd | env: cmd.env ++ [{to_string(key), to_string(value)}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["exec"])
    |> add_flag(cmd.detach, "-d")
    |> add_flag(!cmd.tty, "-T")
    |> add_flag(cmd.privileged, "--privileged")
    |> add_opt(cmd.user, "--user")
    |> add_opt(cmd.workdir, "--workdir")
    |> add_opt(cmd.index && to_string(cmd.index), "--index")
    |> add_repeat(cmd.env, fn {k, v} -> ["-e", "#{k}=#{v}"] end)
    |> Kernel.++([cmd.service])
    |> Kernel.++(cmd.command)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
