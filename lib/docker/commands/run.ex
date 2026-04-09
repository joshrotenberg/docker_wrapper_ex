defmodule Docker.Commands.Run do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker run`.

  Builds a `docker run` command with full support for ports, volumes,
  environment variables, labels, capabilities, and resource constraints.

  ## Examples

      import Docker.Commands.Run

      "nginx:alpine"
      |> new()
      |> name("my-nginx")
      |> port(8080, 80)
      |> detach()
      |> Docker.run()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @type port_mapping :: {non_neg_integer(), non_neg_integer(), String.t()}
  @type volume_mapping :: {String.t(), String.t(), String.t()}
  @type mount_spec :: {String.t(), String.t(), String.t(), keyword()}
  @type env_pair :: {String.t(), String.t()}

  @type t :: %__MODULE__{
          image: String.t(),
          name: String.t() | nil,
          network: String.t() | nil,
          hostname: String.t() | nil,
          workdir: String.t() | nil,
          user: String.t() | nil,
          entrypoint: String.t() | nil,
          platform: String.t() | nil,
          restart: String.t() | nil,
          memory: String.t() | nil,
          cpus: String.t() | nil,
          pid: String.t() | nil,
          ipc: String.t() | nil,
          shm_size: String.t() | nil,
          runtime: String.t() | nil,
          log_driver: String.t() | nil,
          command: [String.t()] | nil,
          ports: [port_mapping()],
          volumes: [volume_mapping()],
          mounts: [mount_spec()],
          env: [env_pair()],
          env_file: [String.t()],
          labels: [env_pair()],
          cap_add: [String.t()],
          cap_drop: [String.t()],
          devices: [String.t()],
          dns: [String.t()],
          extra_hosts: [{String.t(), String.t()}],
          tmpfs: [String.t()],
          log_opts: [env_pair()],
          health_cmd: String.t() | nil,
          health_interval: String.t() | nil,
          health_timeout: String.t() | nil,
          health_retries: non_neg_integer() | nil,
          detach: boolean(),
          rm: boolean(),
          interactive: boolean(),
          tty: boolean(),
          privileged: boolean(),
          read_only: boolean(),
          init: boolean(),
          extra_args: [String.t()]
        }

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
    :pid,
    :ipc,
    :shm_size,
    :runtime,
    :log_driver,
    :health_cmd,
    :health_interval,
    :health_timeout,
    :health_retries,
    command: nil,
    ports: [],
    volumes: [],
    mounts: [],
    env: [],
    env_file: [],
    labels: [],
    cap_add: [],
    cap_drop: [],
    devices: [],
    dns: [],
    extra_hosts: [],
    tmpfs: [],
    log_opts: [],
    detach: false,
    rm: false,
    interactive: false,
    tty: false,
    privileged: false,
    read_only: false,
    init: false,
    extra_args: []
  ]

  @doc "Creates a new run command for the given image."
  @spec new(String.t()) :: t()
  def new(image), do: %__MODULE__{image: image}

  @doc "Sets the container name."
  def name(%__MODULE__{} = cmd, n), do: %{cmd | name: n}

  @doc "Sets the network."
  def network(%__MODULE__{} = cmd, n), do: %{cmd | network: n}

  @doc "Sets the hostname."
  def hostname(%__MODULE__{} = cmd, h), do: %{cmd | hostname: h}

  @doc "Sets the working directory inside the container."
  def workdir(%__MODULE__{} = cmd, w), do: %{cmd | workdir: w}

  @doc "Sets the user."
  def user(%__MODULE__{} = cmd, u), do: %{cmd | user: u}

  @doc "Sets the entrypoint."
  def entrypoint(%__MODULE__{} = cmd, e), do: %{cmd | entrypoint: e}

  @doc "Sets the platform."
  def platform(%__MODULE__{} = cmd, p), do: %{cmd | platform: p}

  @doc "Sets the restart policy."
  def restart(%__MODULE__{} = cmd, r), do: %{cmd | restart: r}

  @doc "Sets the memory limit."
  def memory(%__MODULE__{} = cmd, m), do: %{cmd | memory: m}

  @doc "Sets the CPU limit."
  def cpus(%__MODULE__{} = cmd, c), do: %{cmd | cpus: to_string(c)}

  @doc "Sets the PID namespace."
  def pid(%__MODULE__{} = cmd, p), do: %{cmd | pid: p}

  @doc "Sets the IPC namespace."
  def ipc(%__MODULE__{} = cmd, i), do: %{cmd | ipc: i}

  @doc "Sets the shared memory size."
  def shm_size(%__MODULE__{} = cmd, s), do: %{cmd | shm_size: s}

  @doc "Sets the runtime."
  def runtime(%__MODULE__{} = cmd, r), do: %{cmd | runtime: r}

  @doc "Sets the logging driver."
  def log_driver(%__MODULE__{} = cmd, d), do: %{cmd | log_driver: d}

  @doc "Adds a port mapping."
  @spec port(t(), non_neg_integer(), non_neg_integer(), keyword()) :: t()
  def port(%__MODULE__{} = cmd, host, container, opts \\ []) do
    proto = Keyword.get(opts, :protocol, "tcp")
    %{cmd | ports: cmd.ports ++ [{host, container, proto}]}
  end

  @doc "Adds a volume mount."
  @spec volume(t(), String.t(), String.t(), keyword()) :: t()
  def volume(%__MODULE__{} = cmd, host, container, opts \\ []) do
    mode = Keyword.get(opts, :mode, "rw")
    %{cmd | volumes: cmd.volumes ++ [{host, container, mode}]}
  end

  @doc "Adds a mount specification."
  @spec mount(t(), String.t(), String.t(), String.t(), keyword()) :: t()
  def mount(%__MODULE__{} = cmd, type, source, target, opts \\ []) do
    %{cmd | mounts: cmd.mounts ++ [{type, source, target, opts}]}
  end

  @doc "Adds an environment variable."
  def env(%__MODULE__{} = cmd, key, value) do
    %{cmd | env: cmd.env ++ [{to_string(key), to_string(value)}]}
  end

  @doc "Adds an env file."
  def env_file(%__MODULE__{} = cmd, path) do
    %{cmd | env_file: cmd.env_file ++ [path]}
  end

  @doc "Adds a label."
  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  @doc "Adds a Linux capability."
  def cap_add(%__MODULE__{} = cmd, cap), do: %{cmd | cap_add: cmd.cap_add ++ [cap]}

  @doc "Drops a Linux capability."
  def cap_drop(%__MODULE__{} = cmd, cap), do: %{cmd | cap_drop: cmd.cap_drop ++ [cap]}

  @doc "Adds a device."
  def device(%__MODULE__{} = cmd, d), do: %{cmd | devices: cmd.devices ++ [d]}

  @doc "Adds a DNS server."
  def dns(%__MODULE__{} = cmd, d), do: %{cmd | dns: cmd.dns ++ [d]}

  @doc "Adds an extra host mapping."
  def extra_host(%__MODULE__{} = cmd, host, ip) do
    %{cmd | extra_hosts: cmd.extra_hosts ++ [{host, ip}]}
  end

  @doc "Adds a tmpfs mount."
  def tmpfs(%__MODULE__{} = cmd, t), do: %{cmd | tmpfs: cmd.tmpfs ++ [t]}

  @doc "Adds a log option."
  def log_opt(%__MODULE__{} = cmd, key, value) do
    %{cmd | log_opts: cmd.log_opts ++ [{to_string(key), to_string(value)}]}
  end

  @doc "Sets the health check command."
  def health_cmd(%__MODULE__{} = cmd, c), do: %{cmd | health_cmd: c}

  @doc "Sets the health check interval."
  def health_interval(%__MODULE__{} = cmd, i), do: %{cmd | health_interval: i}

  @doc "Sets the health check timeout."
  def health_timeout(%__MODULE__{} = cmd, t), do: %{cmd | health_timeout: t}

  @doc "Sets the health check retries."
  def health_retries(%__MODULE__{} = cmd, r), do: %{cmd | health_retries: r}

  @doc "Runs in detached mode."
  def detach(%__MODULE__{} = cmd), do: %{cmd | detach: true}

  @doc "Removes the container on exit."
  def rm(%__MODULE__{} = cmd), do: %{cmd | rm: true}

  @doc "Enables interactive mode."
  def interactive(%__MODULE__{} = cmd), do: %{cmd | interactive: true}

  @doc "Allocates a pseudo-TTY."
  def tty(%__MODULE__{} = cmd), do: %{cmd | tty: true}

  @doc "Runs in privileged mode."
  def privileged(%__MODULE__{} = cmd), do: %{cmd | privileged: true}

  @doc "Mounts the root filesystem as read-only."
  def read_only(%__MODULE__{} = cmd), do: %{cmd | read_only: true}

  @doc "Runs an init process inside the container."
  def init_flag(%__MODULE__{} = cmd), do: %{cmd | init: true}

  @doc "Sets the command to run inside the container."
  @spec command(t(), String.t() | [String.t()]) :: t()
  def command(%__MODULE__{} = cmd, args) when is_list(args), do: %{cmd | command: args}
  def command(%__MODULE__{} = cmd, arg) when is_binary(arg), do: %{cmd | command: [arg]}

  @doc "Adds raw extra arguments to the command."
  @spec raw(t(), [String.t()]) :: t()
  def raw(%__MODULE__{} = cmd, args) when is_list(args) do
    %{cmd | extra_args: cmd.extra_args ++ args}
  end

  @doc "Adds a raw flag and value to the command."
  @spec raw(t(), String.t(), String.t()) :: t()
  def raw(%__MODULE__{} = cmd, flag, value) do
    %{cmd | extra_args: cmd.extra_args ++ [flag, to_string(value)]}
  end

  # -- Docker.Command callbacks --

  @impl true
  def args(%__MODULE__{} = cmd) do
    args =
      ["run"]
      |> add_flag(cmd.detach, "-d")
      |> add_flag(cmd.rm, "--rm")
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
      |> add_opt(cmd.pid, "--pid")
      |> add_opt(cmd.ipc, "--ipc")
      |> add_opt(cmd.shm_size, "--shm-size")
      |> add_opt(cmd.runtime, "--runtime")
      |> add_opt(cmd.log_driver, "--log-driver")
      |> add_repeat(cmd.ports, fn {h, c, p} -> ["-p", "#{h}:#{c}/#{p}"] end)
      |> add_repeat(cmd.volumes, fn {h, c, m} -> ["-v", "#{h}:#{c}:#{m}"] end)
      |> add_repeat(cmd.mounts, &format_mount/1)
      |> add_repeat(cmd.env, fn {k, v} -> ["-e", "#{k}=#{v}"] end)
      |> add_repeat(cmd.env_file, fn f -> ["--env-file", f] end)
      |> add_repeat(cmd.labels, fn {k, v} -> ["-l", "#{k}=#{v}"] end)
      |> add_repeat(cmd.cap_add, fn c -> ["--cap-add", c] end)
      |> add_repeat(cmd.cap_drop, fn c -> ["--cap-drop", c] end)
      |> add_repeat(cmd.devices, fn d -> ["--device", d] end)
      |> add_repeat(cmd.dns, fn d -> ["--dns", d] end)
      |> add_repeat(cmd.extra_hosts, fn {h, ip} -> ["--add-host", "#{h}:#{ip}"] end)
      |> add_repeat(cmd.tmpfs, fn t -> ["--tmpfs", t] end)
      |> add_repeat(cmd.log_opts, fn {k, v} -> ["--log-opt", "#{k}=#{v}"] end)
      |> add_opt(cmd.health_cmd, "--health-cmd")
      |> add_opt(cmd.health_interval, "--health-interval")
      |> add_opt(cmd.health_timeout, "--health-timeout")
      |> add_opt(cmd.health_retries && to_string(cmd.health_retries), "--health-retries")
      |> Kernel.++(cmd.extra_args)
      |> Kernel.++([cmd.image])
      |> Kernel.++(cmd.command || [])

    args
  end

  @impl true
  def parse_output(stdout, 0) do
    {:ok, Docker.ContainerId.parse(stdout)}
  end

  def parse_output(stdout, exit_code) do
    {:error, {stdout, exit_code}}
  end

  defp format_mount({type, source, target, opts}) do
    parts = ["type=#{type}", "source=#{source}", "target=#{target}"]
    extra = Enum.map(opts, fn {k, v} -> "#{k}=#{v}" end)
    ["--mount", Enum.join(parts ++ extra, ",")]
  end
end
