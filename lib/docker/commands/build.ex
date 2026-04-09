defmodule Docker.Commands.Build do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker build`.

  ## Examples

      import Docker.Commands.Build

      "."
      |> new()
      |> tag("myapp:latest")
      |> build_arg("VERSION", "1.0")
      |> no_cache()
      |> Docker.build()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          context: String.t(),
          tags: [String.t()],
          file: String.t() | nil,
          target: String.t() | nil,
          platform: String.t() | nil,
          network: String.t() | nil,
          build_args: [{String.t(), String.t()}],
          labels: [{String.t(), String.t()}],
          cache_from: [String.t()],
          no_cache: boolean(),
          pull: boolean(),
          quiet: boolean(),
          rm: boolean(),
          force_rm: boolean(),
          extra_args: [String.t()]
        }

  @enforce_keys [:context]
  defstruct [
    :context,
    :file,
    :target,
    :platform,
    :network,
    tags: [],
    build_args: [],
    labels: [],
    cache_from: [],
    no_cache: false,
    pull: false,
    quiet: false,
    rm: true,
    force_rm: false,
    extra_args: []
  ]

  def new(context), do: %__MODULE__{context: context}

  def tag(%__MODULE__{} = cmd, t), do: %{cmd | tags: cmd.tags ++ [t]}
  def file(%__MODULE__{} = cmd, f), do: %{cmd | file: f}
  def target(%__MODULE__{} = cmd, t), do: %{cmd | target: t}
  def platform(%__MODULE__{} = cmd, p), do: %{cmd | platform: p}
  def network(%__MODULE__{} = cmd, n), do: %{cmd | network: n}

  def build_arg(%__MODULE__{} = cmd, key, value) do
    %{cmd | build_args: cmd.build_args ++ [{to_string(key), to_string(value)}]}
  end

  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  def cache_from(%__MODULE__{} = cmd, c), do: %{cmd | cache_from: cmd.cache_from ++ [c]}
  def no_cache(%__MODULE__{} = cmd), do: %{cmd | no_cache: true}
  def pull(%__MODULE__{} = cmd), do: %{cmd | pull: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def rm(%__MODULE__{} = cmd), do: %{cmd | rm: true}
  def force_rm(%__MODULE__{} = cmd), do: %{cmd | force_rm: true}

  def raw(%__MODULE__{} = cmd, args) when is_list(args) do
    %{cmd | extra_args: cmd.extra_args ++ args}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["build"]
    |> add_flag(cmd.no_cache, "--no-cache")
    |> add_flag(cmd.pull, "--pull")
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.rm, "--rm")
    |> add_flag(cmd.force_rm, "--force-rm")
    |> add_opt(cmd.file, "-f")
    |> add_opt(cmd.target, "--target")
    |> add_opt(cmd.platform, "--platform")
    |> add_opt(cmd.network, "--network")
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
