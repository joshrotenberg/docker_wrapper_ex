defmodule Docker.Commands.Builder.Build do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx build`.

  Extended build with multi-platform, cache, and output options.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @enforce_keys [:context]
  defstruct [
    :context,
    :file,
    :target,
    :builder,
    :output,
    :cache_to,
    tags: [],
    platforms: [],
    build_args: [],
    labels: [],
    cache_from: [],
    no_cache: false,
    pull: false,
    push: false,
    load: false,
    extra_args: []
  ]

  @type t :: %__MODULE__{}

  def new(context), do: %__MODULE__{context: context}

  def tag(%__MODULE__{} = cmd, t), do: %{cmd | tags: cmd.tags ++ [t]}
  def file(%__MODULE__{} = cmd, f), do: %{cmd | file: f}
  def target(%__MODULE__{} = cmd, t), do: %{cmd | target: t}
  def builder(%__MODULE__{} = cmd, b), do: %{cmd | builder: b}
  def output(%__MODULE__{} = cmd, o), do: %{cmd | output: o}
  def cache_to(%__MODULE__{} = cmd, c), do: %{cmd | cache_to: c}
  def platform(%__MODULE__{} = cmd, p), do: %{cmd | platforms: cmd.platforms ++ [p]}
  def no_cache(%__MODULE__{} = cmd), do: %{cmd | no_cache: true}
  def pull(%__MODULE__{} = cmd), do: %{cmd | pull: true}
  def push(%__MODULE__{} = cmd), do: %{cmd | push: true}
  def load(%__MODULE__{} = cmd), do: %{cmd | load: true}

  def build_arg(%__MODULE__{} = cmd, key, value) do
    %{cmd | build_args: cmd.build_args ++ [{to_string(key), to_string(value)}]}
  end

  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  def cache_from(%__MODULE__{} = cmd, c), do: %{cmd | cache_from: cmd.cache_from ++ [c]}

  def raw(%__MODULE__{} = cmd, args) when is_list(args) do
    %{cmd | extra_args: cmd.extra_args ++ args}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    platform_str =
      case cmd.platforms do
        [] -> nil
        ps -> Enum.join(ps, ",")
      end

    ["buildx", "build"]
    |> add_flag(cmd.no_cache, "--no-cache")
    |> add_flag(cmd.pull, "--pull")
    |> add_flag(cmd.push, "--push")
    |> add_flag(cmd.load, "--load")
    |> add_opt(cmd.file, "-f")
    |> add_opt(cmd.target, "--target")
    |> add_opt(cmd.builder, "--builder")
    |> add_opt(cmd.output, "--output")
    |> add_opt(cmd.cache_to, "--cache-to")
    |> add_opt(platform_str, "--platform")
    |> add_repeat(cmd.tags, fn t -> ["-t", t] end)
    |> add_repeat(cmd.build_args, fn {k, v} -> ["--build-arg", "#{k}=#{v}"] end)
    |> add_repeat(cmd.labels, fn {k, v} -> ["--label", "#{k}=#{v}"] end)
    |> add_repeat(cmd.cache_from, fn c -> ["--cache-from", c] end)
    |> Kernel.++(cmd.extra_args)
    |> Kernel.++([cmd.context])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
