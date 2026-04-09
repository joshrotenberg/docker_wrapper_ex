defmodule Docker.Commands.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker create`.

  Creates a container without starting it. Accepts the same options
  as `Docker.Commands.Run` but produces a container ID without running.

  ## Examples

      import Docker.Commands.Create

      "nginx:alpine"
      |> new()
      |> name("my-nginx")
      |> port(8080, 80)
      |> Docker.create()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @enforce_keys [:image]
  defstruct [
    :image,
    :name,
    :network,
    :hostname,
    :workdir,
    :user,
    :entrypoint,
    :platform,
    :restart,
    :memory,
    :cpus,
    command: nil,
    ports: [],
    volumes: [],
    env: [],
    env_file: [],
    labels: [],
    cap_add: [],
    cap_drop: [],
    interactive: false,
    tty: false,
    privileged: false,
    read_only: false,
    init: false,
    extra_args: []
  ]

  @type t :: %__MODULE__{}

  def new(image), do: %__MODULE__{image: image}

  def name(%__MODULE__{} = cmd, n), do: %{cmd | name: n}
  def network(%__MODULE__{} = cmd, n), do: %{cmd | network: n}
  def hostname(%__MODULE__{} = cmd, h), do: %{cmd | hostname: h}
  def workdir(%__MODULE__{} = cmd, w), do: %{cmd | workdir: w}
  def user(%__MODULE__{} = cmd, u), do: %{cmd | user: u}
  def entrypoint(%__MODULE__{} = cmd, e), do: %{cmd | entrypoint: e}
  def platform(%__MODULE__{} = cmd, p), do: %{cmd | platform: p}
  def restart(%__MODULE__{} = cmd, r), do: %{cmd | restart: r}
  def memory(%__MODULE__{} = cmd, m), do: %{cmd | memory: m}
  def cpus(%__MODULE__{} = cmd, c), do: %{cmd | cpus: to_string(c)}

  def port(%__MODULE__{} = cmd, host, container, opts \\ []) do
    proto = Keyword.get(opts, :protocol, "tcp")
    %{cmd | ports: cmd.ports ++ [{host, container, proto}]}
  end

  def volume(%__MODULE__{} = cmd, host, container, opts \\ []) do
    mode = Keyword.get(opts, :mode, "rw")
    %{cmd | volumes: cmd.volumes ++ [{host, container, mode}]}
  end

  def env(%__MODULE__{} = cmd, key, value) do
    %{cmd | env: cmd.env ++ [{to_string(key), to_string(value)}]}
  end

  def env_file(%__MODULE__{} = cmd, path), do: %{cmd | env_file: cmd.env_file ++ [path]}

  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  def cap_add(%__MODULE__{} = cmd, cap), do: %{cmd | cap_add: cmd.cap_add ++ [cap]}
  def cap_drop(%__MODULE__{} = cmd, cap), do: %{cmd | cap_drop: cmd.cap_drop ++ [cap]}
  def interactive(%__MODULE__{} = cmd), do: %{cmd | interactive: true}
  def tty(%__MODULE__{} = cmd), do: %{cmd | tty: true}
  def privileged(%__MODULE__{} = cmd), do: %{cmd | privileged: true}
  def read_only(%__MODULE__{} = cmd), do: %{cmd | read_only: true}
  def init_flag(%__MODULE__{} = cmd), do: %{cmd | init: true}

  def command(%__MODULE__{} = cmd, args) when is_list(args), do: %{cmd | command: args}
  def command(%__MODULE__{} = cmd, arg) when is_binary(arg), do: %{cmd | command: [arg]}

  def raw(%__MODULE__{} = cmd, args) when is_list(args) do
    %{cmd | extra_args: cmd.extra_args ++ args}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["create"]
    |> add_flag(cmd.interactive, "-i")
    |> add_flag(cmd.tty, "-t")
    |> add_flag(cmd.privileged, "--privileged")
    |> add_flag(cmd.read_only, "--read-only")
    |> add_flag(cmd.init, "--init")
    |> add_opt(cmd.name, "--name")
    |> add_opt(cmd.network, "--network")
    |> add_opt(cmd.hostname, "--hostname")
    |> add_opt(cmd.workdir, "--workdir")
    |> add_opt(cmd.user, "--user")
    |> add_opt(cmd.entrypoint, "--entrypoint")
    |> add_opt(cmd.platform, "--platform")
    |> add_opt(cmd.restart, "--restart")
    |> add_opt(cmd.memory, "--memory")
    |> add_opt(cmd.cpus, "--cpus")
    |> add_repeat(cmd.ports, fn {h, c, p} -> ["-p", "#{h}:#{c}/#{p}"] end)
    |> add_repeat(cmd.volumes, fn {h, c, m} -> ["-v", "#{h}:#{c}:#{m}"] end)
    |> add_repeat(cmd.env, fn {k, v} -> ["-e", "#{k}=#{v}"] end)
    |> add_repeat(cmd.env_file, fn f -> ["--env-file", f] end)
    |> add_repeat(cmd.labels, fn {k, v} -> ["-l", "#{k}=#{v}"] end)
    |> add_repeat(cmd.cap_add, fn c -> ["--cap-add", c] end)
    |> add_repeat(cmd.cap_drop, fn c -> ["--cap-drop", c] end)
    |> Kernel.++(cmd.extra_args)
    |> Kernel.++([cmd.image])
    |> Kernel.++(cmd.command || [])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, Docker.ContainerId.parse(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
