# DockerWrapper

[![CI](https://github.com/joshrotenberg/docker_wrapper_ex/actions/workflows/ci.yml/badge.svg)](https://github.com/joshrotenberg/docker_wrapper_ex/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/docker_wrapper.svg)](https://hex.pm/packages/docker_wrapper)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/docker_wrapper)
[![License](https://img.shields.io/hexpm/l/docker_wrapper.svg)](LICENSE)

A typed Elixir wrapper for the Docker CLI. Struct-based commands, pipeline
composition, and BEAM-native extensions for supervised containers and
streaming output.

Elixir port of [docker-wrapper](https://crates.io/crates/docker-wrapper) (Rust).

## Features

- **100+ Docker commands** covering containers, images, networks, volumes, compose, buildx, swarm, manifests, and more
- **Struct-based builders** with pipeline composition for every command
- **Typed results** with `{:ok, result} | {:error, reason}` everywhere
- **JSON parsing** for ps, images, inspect, network/volume listing, and search
- **Platform auto-detection** for docker, podman, and nerdctl
- **Telemetry integration** for observability
- **`Docker.Supervised`** -- GenServer for OTP-supervised container lifecycle with health checks
- **`Docker.Stream`** -- Port-based streaming for `docker logs -f`, `docker events`, builds
- **`Docker.Generic`** -- escape hatch for any command not yet covered
- **Full Compose support** with shared project-level options (`-f`, `-p`, `--profile`)

## Quick start

```elixir
# Run a container
import Docker.Commands.Run

{:ok, container_id} =
  "redis:7-alpine"
  |> new()
  |> name("my-redis")
  |> port(6379, 6379)
  |> detach()
  |> Docker.run()

# List running containers
{:ok, containers} = Docker.ps()

# Exec into a container
{:ok, output} =
  Docker.Commands.Exec.new("my-redis", ["redis-cli", "ping"])
  |> Docker.exec_cmd()

# Stop and remove
{:ok, _} = Docker.stop("my-redis")
{:ok, _} = Docker.rm("my-redis")
```

## Supervised containers

Run containers under OTP supervision with automatic health checks and
cleanup on termination:

```elixir
run_cmd =
  Docker.Commands.Run.new("redis:7-alpine")
  |> Docker.Commands.Run.name("supervised-redis")
  |> Docker.Commands.Run.port(6379, 6379)

{:ok, pid} = Docker.Supervised.start_link(run_cmd,
  health_interval: 5_000,
  rm_on_terminate: true
)

Docker.Supervised.container_id(pid)  #=> "abc123..."
Docker.Supervised.healthy?(pid)      #=> :healthy

# Or under a supervisor
children = [
  {Docker.Supervised, {run_cmd, name: MyApp.Redis}}
]
Supervisor.start_link(children, strategy: :one_for_one)
```

## Streaming

Stream output from long-running commands via Port:

```elixir
{:ok, stream} =
  Docker.Commands.Logs.new("my-container")
  |> Docker.Commands.Logs.follow()
  |> Docker.Stream.start_link(subscriber: self())

receive do
  {:docker_stream, ^stream, {:stdout, line}} -> IO.puts(line)
  {:docker_stream, ^stream, {:exit, 0}} -> :done
end
```

## Compose

```elixir
import Docker.Commands.Compose.Up

new()
|> file("docker-compose.yml")
|> detach()
|> wait()
|> service("redis")
|> service("web")
|> Docker.compose_up()
```

## Images and builds

```elixir
# Pull an image
{:ok, _} = Docker.pull("nginx:alpine")

# Build with buildx for multiple platforms
import Docker.Commands.Builder.Build

"."
|> new()
|> tag("myapp:latest")
|> platform("linux/amd64")
|> platform("linux/arm64")
|> push()
|> Docker.generic()  # or use the builder facade
```

## Networks and volumes

```elixir
# Create a network
{:ok, _} = Docker.network_create("my-net")

# Create a volume
{:ok, _} = Docker.volume_create("my-data")

# Run a container on the network with the volume
"postgres:16"
|> Docker.Commands.Run.new()
|> Docker.Commands.Run.name("my-pg")
|> Docker.Commands.Run.network("my-net")
|> Docker.Commands.Run.volume("my-data", "/var/lib/postgresql/data")
|> Docker.Commands.Run.env("POSTGRES_PASSWORD", "secret")
|> Docker.Commands.Run.detach()
|> Docker.run()
```

## Configuration

The Docker binary, working directory, timeout, and environment can be
configured per-call:

```elixir
config = Docker.Config.new(
  binary: "/usr/local/bin/podman",
  working_dir: "/my/project",
  timeout: 60_000,
  env: [{"DOCKER_HOST", "tcp://remote:2375"}]
)

Docker.ps(config: config)
```

Or set `DOCKER_PATH` to override the binary globally.

### Leak-free execution with forcola (optional)

By default, buffered commands run through `System.cmd/3`. On a timeout or when
the BEAM dies, the Elixir task is torn down but the `docker` CLI OS process and
any local grandchildren it spawned are not group-killed, so a hung `docker
build` or `docker pull` can outlive `{:error, :timeout}`.

The optional [`forcola`](https://hex.pm/packages/forcola) runner places each
child in its own process group and group-kills it (SIGTERM then SIGKILL) on
timeout or BEAM death. Add the dependency and select the runner:

```elixir
# mix.exs
{:forcola, "~> 0.3"}

# per-call
config = Docker.Config.new(runner: :forcola)
Docker.build(build_cmd, config: config)
```

forcola is POSIX-only and ships precompiled binaries, so no Rust toolchain is
required. When it is not loaded (for example on Windows, or if the dependency is
absent), the `:forcola` runner transparently falls back to `:system`.

This governs the `docker` CLI process only. Container lifecycle still uses
docker's own semantics (`docker run --rm`, `docker stop`, `docker kill`), which
`Docker.Supervised` already handles. Streaming commands (`Docker.Stream`) and
the streaming build callback continue to use a Port.

## Installation

Add `docker_wrapper` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:docker_wrapper, "~> 0.1"}
  ]
end
```

## License

MIT
