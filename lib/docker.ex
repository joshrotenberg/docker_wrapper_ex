defmodule Docker do
  @moduledoc """
  A typed Elixir wrapper for the Docker CLI.

  Provides functions for Docker operations by shelling out to the Docker
  binary. Each function accepts an options keyword list that can include
  a `:config` key with a `Docker.Config` struct to customize behavior.

  All functions return `{:ok, result}` on success or `{:error, reason}` on
  failure. A non-zero exit code from Docker produces `{:error, {stdout, exit_code}}`.

  ## Configuration

  Pass a `Docker.Config` struct via the `:config` option to control the Docker
  binary, working directory, environment variables, and command timeout:

      config = Docker.Config.new(
        binary: "/usr/local/bin/podman",
        timeout: 60_000
      )

      Docker.ps(config: config)

  When `:config` is omitted, a default config is built from the environment:
  the binary is located via `DOCKER_PATH` or auto-detected on the PATH,
  and the timeout is 30 seconds.

  ## Pipeline composition

  Commands can be built using struct-based builders and executed via the
  facade functions:

      import Docker.Commands.Run

      "nginx:alpine"
      |> new()
      |> name("my-nginx")
      |> port(8080, 80)
      |> detach()
      |> Docker.run()

  ## Examples

  ### Running a container

      {:ok, container_id} = Docker.run(
        Docker.Commands.Run.new("nginx:alpine")
        |> Docker.Commands.Run.name("my-nginx")
        |> Docker.Commands.Run.detach()
      )

  ### Listing containers

      {:ok, containers} = Docker.ps(all: true)

  ### Stopping a container

      {:ok, _} = Docker.stop("my-nginx")

  """

  alias Docker.{Command, Config}
  alias Docker.Commands

  # -- Container Lifecycle --

  @doc """
  Runs a container from the given command struct or image name.

  When passed a `Docker.Commands.Run` struct, executes it directly.
  When passed a string, creates a basic run command for that image.
  """
  @spec run(Commands.Run.t() | String.t(), keyword()) ::
          {:ok, Docker.ContainerId.t()} | {:error, term()}
  def run(cmd_or_image, opts \\ [])

  def run(%Commands.Run{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Run, cmd, config)
  end

  def run(image, opts) when is_binary(image) do
    run(Commands.Run.new(image), opts)
  end

  @doc """
  Creates a container without starting it.
  """
  @spec create(Commands.Create.t() | String.t(), keyword()) ::
          {:ok, Docker.ContainerId.t()} | {:error, term()}
  def create(cmd_or_image, opts \\ [])

  def create(%Commands.Create{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Create, cmd, config)
  end

  def create(image, opts) when is_binary(image) do
    create(Commands.Create.new(image), opts)
  end

  @doc """
  Starts one or more stopped containers.
  """
  @spec start(Commands.Start.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def start(cmd_or_container, opts \\ [])

  def start(%Commands.Start{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Start, cmd, config)
  end

  def start(container, opts) when is_binary(container) do
    start(Commands.Start.new(container), opts)
  end

  @doc """
  Stops one or more running containers.
  """
  @spec stop(Commands.Stop.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def stop(cmd_or_container, opts \\ [])

  def stop(%Commands.Stop{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Stop, cmd, config)
  end

  def stop(container, opts) when is_binary(container) do
    stop(Commands.Stop.new(container), opts)
  end

  @doc """
  Kills one or more running containers.
  """
  @spec kill(Commands.Kill.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def kill(cmd_or_container, opts \\ [])

  def kill(%Commands.Kill{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Kill, cmd, config)
  end

  def kill(container, opts) when is_binary(container) do
    kill(Commands.Kill.new(container), opts)
  end

  @doc """
  Removes one or more containers.
  """
  @spec rm(Commands.Rm.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def rm(cmd_or_container, opts \\ [])

  def rm(%Commands.Rm{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Rm, cmd, config)
  end

  def rm(container, opts) when is_binary(container) do
    rm(Commands.Rm.new(container), opts)
  end

  @doc """
  Restarts one or more containers.
  """
  @spec restart(Commands.Restart.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def restart(cmd_or_container, opts \\ [])

  def restart(%Commands.Restart{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Restart, cmd, config)
  end

  def restart(container, opts) when is_binary(container) do
    restart(Commands.Restart.new(container), opts)
  end

  @doc """
  Pauses one or more containers.
  """
  @spec pause(Commands.Pause.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def pause(cmd_or_container, opts \\ [])

  def pause(%Commands.Pause{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Pause, cmd, config)
  end

  def pause(container, opts) when is_binary(container) do
    pause(Commands.Pause.new(container), opts)
  end

  @doc """
  Unpauses one or more containers.
  """
  @spec unpause(Commands.Unpause.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def unpause(cmd_or_container, opts \\ [])

  def unpause(%Commands.Unpause{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Unpause, cmd, config)
  end

  def unpause(container, opts) when is_binary(container) do
    unpause(Commands.Unpause.new(container), opts)
  end

  # -- Container Inspection --

  @doc """
  Lists containers.

  ## Options

    * `:all` - show all containers (default: only running)
    * `:config` - a `Docker.Config` struct

  """
  @spec ps(Commands.Ps.t() | keyword()) :: {:ok, [map()]} | {:error, term()}
  def ps(cmd_or_opts \\ [])

  def ps(%Commands.Ps{} = cmd) do
    Command.run(Commands.Ps, cmd, Config.new())
  end

  def ps(opts) when is_list(opts) do
    {config, rest} = extract_config(opts)
    cmd = %Commands.Ps{all: Keyword.get(rest, :all, false)}
    Command.run(Commands.Ps, cmd, config)
  end

  @doc """
  Gets logs from a container.
  """
  @spec logs(Commands.Logs.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def logs(cmd_or_container, opts \\ [])

  def logs(%Commands.Logs{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Logs, cmd, config)
  end

  def logs(container, opts) when is_binary(container) do
    logs(Commands.Logs.new(container), opts)
  end

  @doc """
  Inspects one or more Docker objects (containers, images, networks, volumes).

  Returns parsed JSON as a list of maps.
  """
  @spec inspect_cmd(Commands.Inspect.t() | String.t(), keyword()) ::
          {:ok, [map()]} | {:error, term()}
  def inspect_cmd(cmd_or_target, opts \\ [])

  def inspect_cmd(%Commands.Inspect{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Inspect, cmd, config)
  end

  def inspect_cmd(target, opts) when is_binary(target) do
    inspect_cmd(Commands.Inspect.new(target), opts)
  end

  @doc """
  Executes a command in a running container.
  """
  @spec exec_cmd(Commands.Exec.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def exec_cmd(%Commands.Exec{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Exec, cmd, config)
  end

  # -- Images --

  @doc """
  Lists images.

  ## Options

    * `:all` - show all images including intermediates
    * `:config` - a `Docker.Config` struct

  """
  @spec images(Commands.Images.t() | keyword()) :: {:ok, [map()]} | {:error, term()}
  def images(cmd_or_opts \\ [])

  def images(%Commands.Images{} = cmd) do
    Command.run(Commands.Images, cmd, Config.new())
  end

  def images(opts) when is_list(opts) do
    {config, rest} = extract_config(opts)
    cmd = %Commands.Images{all: Keyword.get(rest, :all, false)}
    Command.run(Commands.Images, cmd, config)
  end

  @doc """
  Pulls an image.
  """
  @spec pull(Commands.Pull.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def pull(cmd_or_image, opts \\ [])

  def pull(%Commands.Pull{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Pull, cmd, config)
  end

  def pull(image, opts) when is_binary(image) do
    pull(Commands.Pull.new(image), opts)
  end

  @doc """
  Pushes an image.
  """
  @spec push(Commands.Push.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def push(cmd_or_image, opts \\ [])

  def push(%Commands.Push{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Push, cmd, config)
  end

  def push(image, opts) when is_binary(image) do
    push(Commands.Push.new(image), opts)
  end

  @doc """
  Builds an image from a Dockerfile.
  """
  @spec build(Commands.Build.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def build(cmd_or_context, opts \\ [])

  def build(%Commands.Build{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Build, cmd, config)
  end

  def build(context, opts) when is_binary(context) do
    build(Commands.Build.new(context), opts)
  end

  @doc """
  Tags an image.
  """
  @spec tag(String.t(), String.t(), keyword()) :: {:ok, :done} | {:error, term()}
  def tag(source, target, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Tag, Commands.Tag.new(source, target), config)
  end

  @doc """
  Removes one or more images.
  """
  @spec rmi(Commands.Rmi.t() | String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def rmi(cmd_or_image, opts \\ [])

  def rmi(%Commands.Rmi{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Rmi, cmd, config)
  end

  def rmi(image, opts) when is_binary(image) do
    rmi(Commands.Rmi.new(image), opts)
  end

  @doc """
  Saves one or more images to a tar archive.
  """
  @spec save(Commands.Save.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def save(%Commands.Save{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Save, cmd, config)
  end

  @doc """
  Loads an image from a tar archive.
  """
  @spec load(Commands.Load.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def load(%Commands.Load{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Load, cmd, config)
  end

  @doc """
  Imports a tarball to create a filesystem image.
  """
  @spec import_image(Commands.Import.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def import_image(%Commands.Import{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Import, cmd, config)
  end

  @doc """
  Shows the history of an image.
  """
  @spec history(Commands.History.t() | String.t(), keyword()) ::
          {:ok, [map()]} | {:error, term()}
  def history(cmd_or_image, opts \\ [])

  def history(%Commands.History{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.History, cmd, config)
  end

  def history(image, opts) when is_binary(image) do
    history(Commands.History.new(image), opts)
  end

  @doc """
  Searches Docker Hub for images.
  """
  @spec search(Commands.Search.t() | String.t(), keyword()) ::
          {:ok, [map()]} | {:error, term()}
  def search(cmd_or_term, opts \\ [])

  def search(%Commands.Search{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Search, cmd, config)
  end

  def search(term, opts) when is_binary(term) do
    search(Commands.Search.new(term), opts)
  end

  # -- Networks --

  @doc """
  Creates a network.
  """
  @spec network_create(Commands.Network.Create.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def network_create(cmd_or_name, opts \\ [])

  def network_create(%Commands.Network.Create{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Create, cmd, config)
  end

  def network_create(name, opts) when is_binary(name) do
    network_create(Commands.Network.Create.new(name), opts)
  end

  @doc """
  Removes one or more networks.
  """
  @spec network_rm(Commands.Network.Rm.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def network_rm(cmd_or_name, opts \\ [])

  def network_rm(%Commands.Network.Rm{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Rm, cmd, config)
  end

  def network_rm(name, opts) when is_binary(name) do
    network_rm(Commands.Network.Rm.new(name), opts)
  end

  @doc """
  Lists networks.
  """
  @spec network_ls(Commands.Network.Ls.t() | keyword()) :: {:ok, [map()]} | {:error, term()}
  def network_ls(cmd_or_opts \\ [])

  def network_ls(%Commands.Network.Ls{} = cmd) do
    Command.run(Commands.Network.Ls, cmd, Config.new())
  end

  def network_ls(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Ls, Commands.Network.Ls.new(), config)
  end

  @doc """
  Inspects one or more networks.
  """
  @spec network_inspect(Commands.Network.Inspect.t() | String.t(), keyword()) ::
          {:ok, [map()]} | {:error, term()}
  def network_inspect(cmd_or_name, opts \\ [])

  def network_inspect(%Commands.Network.Inspect{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Inspect, cmd, config)
  end

  def network_inspect(name, opts) when is_binary(name) do
    network_inspect(Commands.Network.Inspect.new(name), opts)
  end

  @doc """
  Connects a container to a network.
  """
  @spec network_connect(Commands.Network.Connect.t(), keyword()) ::
          {:ok, :done} | {:error, term()}
  def network_connect(%Commands.Network.Connect{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Connect, cmd, config)
  end

  @doc """
  Disconnects a container from a network.
  """
  @spec network_disconnect(Commands.Network.Disconnect.t(), keyword()) ::
          {:ok, :done} | {:error, term()}
  def network_disconnect(%Commands.Network.Disconnect{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Disconnect, cmd, config)
  end

  @doc """
  Removes all unused networks.
  """
  @spec network_prune(Commands.Network.Prune.t() | keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def network_prune(cmd_or_opts \\ [])

  def network_prune(%Commands.Network.Prune{} = cmd) do
    Command.run(Commands.Network.Prune, cmd, Config.new())
  end

  def network_prune(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Network.Prune, Commands.Network.Prune.new(), config)
  end

  # -- Volumes --

  @doc """
  Creates a volume.
  """
  @spec volume_create(Commands.Volume.Create.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def volume_create(cmd_or_name \\ %Commands.Volume.Create{}, opts \\ [])

  def volume_create(%Commands.Volume.Create{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Volume.Create, cmd, config)
  end

  def volume_create(name, opts) when is_binary(name) do
    volume_create(Commands.Volume.Create.new(name), opts)
  end

  @doc """
  Removes one or more volumes.
  """
  @spec volume_rm(Commands.Volume.Rm.t() | String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def volume_rm(cmd_or_name, opts \\ [])

  def volume_rm(%Commands.Volume.Rm{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Volume.Rm, cmd, config)
  end

  def volume_rm(name, opts) when is_binary(name) do
    volume_rm(Commands.Volume.Rm.new(name), opts)
  end

  @doc """
  Lists volumes.
  """
  @spec volume_ls(Commands.Volume.Ls.t() | keyword()) :: {:ok, [map()]} | {:error, term()}
  def volume_ls(cmd_or_opts \\ [])

  def volume_ls(%Commands.Volume.Ls{} = cmd) do
    Command.run(Commands.Volume.Ls, cmd, Config.new())
  end

  def volume_ls(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Volume.Ls, Commands.Volume.Ls.new(), config)
  end

  @doc """
  Inspects one or more volumes.
  """
  @spec volume_inspect(Commands.Volume.Inspect.t() | String.t(), keyword()) ::
          {:ok, [map()]} | {:error, term()}
  def volume_inspect(cmd_or_name, opts \\ [])

  def volume_inspect(%Commands.Volume.Inspect{} = cmd, opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Volume.Inspect, cmd, config)
  end

  def volume_inspect(name, opts) when is_binary(name) do
    volume_inspect(Commands.Volume.Inspect.new(name), opts)
  end

  @doc """
  Removes all unused volumes.
  """
  @spec volume_prune(Commands.Volume.Prune.t() | keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def volume_prune(cmd_or_opts \\ [])

  def volume_prune(%Commands.Volume.Prune{} = cmd) do
    Command.run(Commands.Volume.Prune, cmd, Config.new())
  end

  def volume_prune(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Volume.Prune, Commands.Volume.Prune.new(), config)
  end

  # -- Prune --

  @doc """
  Removes all stopped containers.
  """
  @spec container_prune(Commands.ContainerPrune.t() | keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def container_prune(cmd_or_opts \\ [])

  def container_prune(%Commands.ContainerPrune{} = cmd) do
    Command.run(Commands.ContainerPrune, cmd, Config.new())
  end

  def container_prune(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.ContainerPrune, Commands.ContainerPrune.new(), config)
  end

  @doc """
  Removes unused images.
  """
  @spec image_prune(Commands.ImagePrune.t() | keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def image_prune(cmd_or_opts \\ [])

  def image_prune(%Commands.ImagePrune{} = cmd) do
    Command.run(Commands.ImagePrune, cmd, Config.new())
  end

  def image_prune(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.ImagePrune, Commands.ImagePrune.new(), config)
  end

  # -- Compose --

  @doc "Runs `docker compose up`."
  @spec compose_up(Commands.Compose.Up.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def compose_up(%Commands.Compose.Up{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Up, cmd, config)
  end

  @doc "Runs `docker compose down`."
  @spec compose_down(Commands.Compose.Down.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def compose_down(%Commands.Compose.Down{} = cmd \\ %Commands.Compose.Down{}, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Down, cmd, config)
  end

  @doc "Runs `docker compose ps`."
  @spec compose_ps(Commands.Compose.Ps.t(), keyword()) :: {:ok, [map()]} | {:error, term()}
  def compose_ps(%Commands.Compose.Ps{} = cmd \\ %Commands.Compose.Ps{}, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Ps, cmd, config)
  end

  @doc "Runs `docker compose logs`."
  @spec compose_logs(Commands.Compose.Logs.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def compose_logs(%Commands.Compose.Logs{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Logs, cmd, config)
  end

  @doc "Runs `docker compose exec`."
  @spec compose_exec(Commands.Compose.Exec.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def compose_exec(%Commands.Compose.Exec{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Exec, cmd, config)
  end

  @doc "Runs `docker compose run`."
  @spec compose_run(Commands.Compose.Run.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def compose_run(%Commands.Compose.Run{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Run, cmd, config)
  end

  @doc "Runs `docker compose build`."
  @spec compose_build(Commands.Compose.Build.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def compose_build(%Commands.Compose.Build{} = cmd \\ %Commands.Compose.Build{}, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Build, cmd, config)
  end

  @doc "Runs `docker compose config`."
  @spec compose_config(Commands.Compose.Config.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def compose_config(%Commands.Compose.Config{} = cmd \\ %Commands.Compose.Config{}, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Compose.Config, cmd, config)
  end

  # -- System --

  @doc "Runs `docker version`."
  @spec version(keyword()) :: {:ok, term()} | {:error, term()}
  def version(opts \\ []) do
    {config, _rest} = extract_config(opts)
    alias Commands.System.Version, as: Ver
    Command.run(Ver, Ver.new() |> Ver.json(), config)
  end

  @doc "Runs `docker info`."
  @spec info(keyword()) :: {:ok, term()} | {:error, term()}
  def info(opts \\ []) do
    {config, _rest} = extract_config(opts)
    alias Commands.System.Info, as: SysInfo
    Command.run(SysInfo, SysInfo.new() |> SysInfo.json(), config)
  end

  @doc "Runs `docker system df`."
  @spec system_df(Commands.System.Df.t() | keyword()) :: {:ok, String.t()} | {:error, term()}
  def system_df(cmd_or_opts \\ [])

  def system_df(%Commands.System.Df{} = cmd) do
    Command.run(Commands.System.Df, cmd, Config.new())
  end

  def system_df(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    alias Commands.System.Df, as: SysDf
    Command.run(SysDf, SysDf.new(), config)
  end

  @doc "Runs `docker system prune`."
  @spec system_prune(Commands.System.Prune.t() | keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def system_prune(cmd_or_opts \\ [])

  def system_prune(%Commands.System.Prune{} = cmd) do
    Command.run(Commands.System.Prune, cmd, Config.new())
  end

  def system_prune(opts) when is_list(opts) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.System.Prune, Commands.System.Prune.new(), config)
  end

  # -- Generic --

  @doc """
  Runs an arbitrary Docker command via the escape hatch.

  ## Examples

      Docker.generic(Docker.Commands.Generic.new(["system", "events"]))

  """
  @spec generic(Commands.Generic.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def generic(%Commands.Generic{} = cmd, opts \\ []) do
    {config, _rest} = extract_config(opts)
    Command.run(Commands.Generic, cmd, config)
  end

  # -- Helpers --

  defp extract_config(opts) do
    {config, rest} = Keyword.pop(opts, :config, Config.new())
    {config, rest}
  end
end
