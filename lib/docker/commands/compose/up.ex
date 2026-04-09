defmodule Docker.Commands.Compose.Up do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose up`.

  ## Examples

      import Docker.Commands.Compose.Up

      new()
      |> file("docker-compose.yml")
      |> detach()
      |> build()
      |> service("redis")
      |> Docker.compose_up()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              detach: false,
              build_flag: false,
              no_build: false,
              force_recreate: false,
              no_recreate: false,
              no_start: false,
              remove_orphans: false,
              abort_on_container_exit: false,
              always_recreate_deps: false,
              wait: false,
              timeout: nil,
              scale: [],
              pull: nil,
              quiet_pull: false,
              no_deps: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def project_directory(%__MODULE__{} = cmd, d), do: %{cmd | project_directory: d}
  def env_file(%__MODULE__{} = cmd, f), do: %{cmd | env_files: cmd.env_files ++ [f]}
  def profile(%__MODULE__{} = cmd, p), do: %{cmd | profiles: cmd.profiles ++ [p]}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def detach(%__MODULE__{} = cmd), do: %{cmd | detach: true}
  def build(%__MODULE__{} = cmd), do: %{cmd | build_flag: true}
  def no_build(%__MODULE__{} = cmd), do: %{cmd | no_build: true}
  def force_recreate(%__MODULE__{} = cmd), do: %{cmd | force_recreate: true}
  def no_recreate(%__MODULE__{} = cmd), do: %{cmd | no_recreate: true}
  def no_start(%__MODULE__{} = cmd), do: %{cmd | no_start: true}
  def remove_orphans(%__MODULE__{} = cmd), do: %{cmd | remove_orphans: true}
  def abort_on_container_exit(%__MODULE__{} = cmd), do: %{cmd | abort_on_container_exit: true}
  def always_recreate_deps(%__MODULE__{} = cmd), do: %{cmd | always_recreate_deps: true}
  def wait(%__MODULE__{} = cmd), do: %{cmd | wait: true}
  def timeout(%__MODULE__{} = cmd, t), do: %{cmd | timeout: t}
  def quiet_pull(%__MODULE__{} = cmd), do: %{cmd | quiet_pull: true}
  def no_deps(%__MODULE__{} = cmd), do: %{cmd | no_deps: true}
  def pull_policy(%__MODULE__{} = cmd, p), do: %{cmd | pull: p}

  def scale(%__MODULE__{} = cmd, service, count) do
    %{cmd | scale: cmd.scale ++ [{service, count}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["up"])
    |> add_flag(cmd.detach, "-d")
    |> add_flag(cmd.build_flag, "--build")
    |> add_flag(cmd.no_build, "--no-build")
    |> add_flag(cmd.force_recreate, "--force-recreate")
    |> add_flag(cmd.no_recreate, "--no-recreate")
    |> add_flag(cmd.no_start, "--no-start")
    |> add_flag(cmd.remove_orphans, "--remove-orphans")
    |> add_flag(cmd.abort_on_container_exit, "--abort-on-container-exit")
    |> add_flag(cmd.always_recreate_deps, "--always-recreate-deps")
    |> add_flag(cmd.wait, "--wait")
    |> add_flag(cmd.quiet_pull, "--quiet-pull")
    |> add_flag(cmd.no_deps, "--no-deps")
    |> add_opt(cmd.timeout && to_string(cmd.timeout), "-t")
    |> add_opt(cmd.pull, "--pull")
    |> add_repeat(cmd.scale, fn {s, c} -> ["--scale", "#{s}=#{c}"] end)
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
