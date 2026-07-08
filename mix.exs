defmodule DockerWrapper.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/joshrotenberg/docker_wrapper_ex"

  def project do
    [
      app: :docker_wrapper,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      description:
        "A typed Elixir wrapper for the Docker CLI with struct-based commands and pipeline composition",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs(),
      deps: deps(),
      dialyzer: [plt_file: {:no_warn, "_build/dev/dialyxir_#{System.otp_release()}.plt"}]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.2"},
      {:forcola, "~> 0.3", optional: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "Docker",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "LICENSE"],
      groups_for_modules: [
        Core: [
          Docker,
          Docker.Command,
          Docker.Config
        ],
        "Data Structures": [
          Docker.Result,
          Docker.Error,
          Docker.ContainerId
        ],
        "Container Lifecycle": [
          Docker.Commands.Run,
          Docker.Commands.Create,
          Docker.Commands.Start,
          Docker.Commands.Stop,
          Docker.Commands.Kill,
          Docker.Commands.Rm,
          Docker.Commands.Restart,
          Docker.Commands.Pause,
          Docker.Commands.Unpause
        ],
        "Container Inspection": [
          Docker.Commands.Ps,
          Docker.Commands.Logs,
          Docker.Commands.Inspect,
          Docker.Commands.Exec
        ],
        Images: [
          Docker.Commands.Images,
          Docker.Commands.Pull,
          Docker.Commands.Push,
          Docker.Commands.Build,
          Docker.Commands.Tag,
          Docker.Commands.Rmi,
          Docker.Commands.Save,
          Docker.Commands.Load,
          Docker.Commands.Import,
          Docker.Commands.History,
          Docker.Commands.Search
        ],
        Networks: [
          Docker.Commands.Network.Create,
          Docker.Commands.Network.Rm,
          Docker.Commands.Network.Ls,
          Docker.Commands.Network.Inspect,
          Docker.Commands.Network.Connect,
          Docker.Commands.Network.Disconnect,
          Docker.Commands.Network.Prune
        ],
        Volumes: [
          Docker.Commands.Volume.Create,
          Docker.Commands.Volume.Rm,
          Docker.Commands.Volume.Ls,
          Docker.Commands.Volume.Inspect,
          Docker.Commands.Volume.Prune
        ],
        Compose: [
          Docker.Commands.Compose.Up,
          Docker.Commands.Compose.Down,
          Docker.Commands.Compose.Ps,
          Docker.Commands.Compose.Logs,
          Docker.Commands.Compose.Exec,
          Docker.Commands.Compose.Run,
          Docker.Commands.Compose.Build,
          Docker.Commands.Compose.Config,
          Docker.Commands.Compose.Pull,
          Docker.Commands.Compose.Push,
          Docker.Commands.Compose.Start,
          Docker.Commands.Compose.Stop,
          Docker.Commands.Compose.Restart,
          Docker.Commands.Compose.Rm,
          Docker.Commands.Compose.Top,
          Docker.Commands.Compose.Port,
          Docker.Commands.Compose.Images,
          Docker.Commands.Compose.Create,
          Docker.Commands.Compose.Common
        ],
        "Builder / Buildx": [
          Docker.Commands.Builder.Create,
          Docker.Commands.Builder.Inspect,
          Docker.Commands.Builder.Ls,
          Docker.Commands.Builder.Rm,
          Docker.Commands.Builder.Stop,
          Docker.Commands.Builder.Use,
          Docker.Commands.Builder.Build,
          Docker.Commands.Builder.Bake,
          Docker.Commands.Builder.Prune
        ],
        System: [
          Docker.Commands.System.Version,
          Docker.Commands.System.Info,
          Docker.Commands.System.Events,
          Docker.Commands.System.Df,
          Docker.Commands.System.Prune,
          Docker.Commands.System.Login,
          Docker.Commands.System.Logout
        ],
        Context: [
          Docker.Commands.Context.Create,
          Docker.Commands.Context.Inspect,
          Docker.Commands.Context.Ls,
          Docker.Commands.Context.Rm,
          Docker.Commands.Context.Update,
          Docker.Commands.Context.Use
        ],
        Swarm: [
          Docker.Commands.Swarm.Init,
          Docker.Commands.Swarm.Join,
          Docker.Commands.Swarm.Leave,
          Docker.Commands.Swarm.Update,
          Docker.Commands.Swarm.JoinToken,
          Docker.Commands.Swarm.Ca,
          Docker.Commands.Swarm.Unlock,
          Docker.Commands.Swarm.UnlockKey
        ],
        Manifest: [
          Docker.Commands.Manifest.Create,
          Docker.Commands.Manifest.Inspect,
          Docker.Commands.Manifest.Push,
          Docker.Commands.Manifest.Rm,
          Docker.Commands.Manifest.Annotate
        ],
        Prune: [
          Docker.Commands.ContainerPrune,
          Docker.Commands.ImagePrune
        ],
        "BEAM Extensions": [
          Docker.Supervised,
          Docker.Stream
        ],
        Debug: [
          Docker.Debug.Config,
          Docker.Debug.Retry,
          Docker.Debug.Executor
        ],
        Internals: [
          Docker.Commands.Generic,
          Docker.Commands.Init,
          Docker.Telemetry
        ]
      ]
    ]
  end
end
