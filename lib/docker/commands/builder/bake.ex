defmodule Docker.Commands.Builder.Bake do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx bake`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  defstruct [
    :file,
    :builder,
    targets: [],
    set: [],
    no_cache: false,
    pull: false,
    push: false,
    load: false,
    print: false
  ]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | file: f}
  def builder(%__MODULE__{} = cmd, b), do: %{cmd | builder: b}
  def target(%__MODULE__{} = cmd, t), do: %{cmd | targets: cmd.targets ++ [t]}
  def set(%__MODULE__{} = cmd, key, value), do: %{cmd | set: cmd.set ++ [{key, value}]}
  def no_cache(%__MODULE__{} = cmd), do: %{cmd | no_cache: true}
  def pull(%__MODULE__{} = cmd), do: %{cmd | pull: true}
  def push(%__MODULE__{} = cmd), do: %{cmd | push: true}
  def load(%__MODULE__{} = cmd), do: %{cmd | load: true}
  def print(%__MODULE__{} = cmd), do: %{cmd | print: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["buildx", "bake"]
    |> add_flag(cmd.no_cache, "--no-cache")
    |> add_flag(cmd.pull, "--pull")
    |> add_flag(cmd.push, "--push")
    |> add_flag(cmd.load, "--load")
    |> add_flag(cmd.print, "--print")
    |> add_opt(cmd.file, "-f")
    |> add_opt(cmd.builder, "--builder")
    |> add_repeat(cmd.set, fn {k, v} -> ["--set", "#{k}=#{v}"] end)
    |> Kernel.++(cmd.targets)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
