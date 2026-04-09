defmodule Docker.Commands.Compose.Run do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose run`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              service: nil,
              command: [],
              detach: false,
              rm: false,
              no_deps: false,
              name: nil,
              user: nil,
              workdir: nil,
              entrypoint: nil,
              env: [],
              labels: [],
              volumes: [],
              ports: [],
              service_ports: false,
              use_aliases: false,
              no_tty: false,
              build_flag: false,
              quiet_pull: false
            )

  @type t :: %__MODULE__{}

  def new(service), do: %__MODULE__{service: service}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def command(%__MODULE__{} = cmd, c) when is_list(c), do: %{cmd | command: c}
  def command(%__MODULE__{} = cmd, c) when is_binary(c), do: %{cmd | command: [c]}
  def detach(%__MODULE__{} = cmd), do: %{cmd | detach: true}
  def rm(%__MODULE__{} = cmd), do: %{cmd | rm: true}
  def no_deps(%__MODULE__{} = cmd), do: %{cmd | no_deps: true}
  def name(%__MODULE__{} = cmd, n), do: %{cmd | name: n}
  def user(%__MODULE__{} = cmd, u), do: %{cmd | user: u}
  def workdir(%__MODULE__{} = cmd, w), do: %{cmd | workdir: w}
  def entrypoint(%__MODULE__{} = cmd, e), do: %{cmd | entrypoint: e}
  def service_ports(%__MODULE__{} = cmd), do: %{cmd | service_ports: true}
  def use_aliases(%__MODULE__{} = cmd), do: %{cmd | use_aliases: true}
  def no_tty(%__MODULE__{} = cmd), do: %{cmd | no_tty: true}
  def build(%__MODULE__{} = cmd), do: %{cmd | build_flag: true}
  def quiet_pull(%__MODULE__{} = cmd), do: %{cmd | quiet_pull: true}

  def env(%__MODULE__{} = cmd, key, value) do
    %{cmd | env: cmd.env ++ [{to_string(key), to_string(value)}]}
  end

  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  def volume(%__MODULE__{} = cmd, v), do: %{cmd | volumes: cmd.volumes ++ [v]}

  def port(%__MODULE__{} = cmd, p), do: %{cmd | ports: cmd.ports ++ [to_string(p)]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["run"])
    |> add_flag(cmd.detach, "-d")
    |> add_flag(cmd.rm, "--rm")
    |> add_flag(cmd.no_deps, "--no-deps")
    |> add_flag(cmd.service_ports, "--service-ports")
    |> add_flag(cmd.use_aliases, "--use-aliases")
    |> add_flag(cmd.no_tty, "-T")
    |> add_flag(cmd.build_flag, "--build")
    |> add_flag(cmd.quiet_pull, "--quiet-pull")
    |> add_opt(cmd.name, "--name")
    |> add_opt(cmd.user, "--user")
    |> add_opt(cmd.workdir, "--workdir")
    |> add_opt(cmd.entrypoint, "--entrypoint")
    |> add_repeat(cmd.env, fn {k, v} -> ["-e", "#{k}=#{v}"] end)
    |> add_repeat(cmd.labels, fn {k, v} -> ["-l", "#{k}=#{v}"] end)
    |> add_repeat(cmd.volumes, fn v -> ["-v", v] end)
    |> add_repeat(cmd.ports, fn p -> ["-p", p] end)
    |> Kernel.++([cmd.service])
    |> Kernel.++(cmd.command)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
