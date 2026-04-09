# Changelog

## 0.1.0 (Unreleased)

### Features

- Core execution layer with `Docker.Command` behaviour, `Docker.Config`, telemetry
- Container lifecycle: run, create, start, stop, kill, rm, restart, pause, unpause
- Container inspection: ps, logs, inspect, exec
- Image management: images, pull, push, build, tag, rmi, save, load, import, history, search
- Network management: create, rm, ls, inspect, connect, disconnect, prune
- Volume management: create, rm, ls, inspect, prune
- Compose: up, down, ps, logs, exec, run, build, config, pull, push, start, stop, restart, rm, top, port, images, create
- Buildx/Builder: create, inspect, ls, rm, stop, use, build, bake, prune
- System: version, info, events, df, prune, login, logout
- Context: create, inspect, ls, rm, update, use
- Swarm: init, join, leave, update, join-token, ca, unlock, unlock-key
- Manifest: create, inspect, push, rm, annotate
- Container/image prune commands
- `Docker.Generic` escape hatch for arbitrary commands
- `Docker.Supervised` -- GenServer for OTP-supervised container lifecycle
- `Docker.Stream` -- Port-based streaming for long-running commands
- Platform auto-detection (docker, podman, nerdctl)
