# Changelog

## [0.1.2](https://github.com/joshrotenberg/docker_wrapper_ex/compare/v0.1.1...v0.1.2) (2026-04-09)


### Features

* integration tests, debug/retry executor, per-execution binary override ([#9](https://github.com/joshrotenberg/docker_wrapper_ex/issues/9)) ([eaf8399](https://github.com/joshrotenberg/docker_wrapper_ex/commit/eaf8399f5cdcafba103b94f0449e31029403c2e0))
* stream callback option for any Docker command ([#11](https://github.com/joshrotenberg/docker_wrapper_ex/issues/11)) ([ec3da86](https://github.com/joshrotenberg/docker_wrapper_ex/commit/ec3da86638aca8b975412c1d1e9936b814d4272e)), closes [#6](https://github.com/joshrotenberg/docker_wrapper_ex/issues/6)

## [0.1.1](https://github.com/joshrotenberg/docker_wrapper_ex/compare/v0.1.0...v0.1.1) (2026-04-09)


### Features

* initial implementation -- typed Docker CLI wrapper for Elixir ([6fe3e6d](https://github.com/joshrotenberg/docker_wrapper_ex/commit/6fe3e6dfbfc8ad2fc68122de2ef693de15c3b95f))

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
