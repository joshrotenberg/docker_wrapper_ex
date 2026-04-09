defmodule Docker.Commands.Compose.Build do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose build`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_repeat: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              services: [],
              no_cache: false,
              pull: false,
              quiet: false,
              build_args: [],
              parallel: false
            )

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def service(%__MODULE__{} = cmd, s), do: %{cmd | services: cmd.services ++ [s]}
  def no_cache(%__MODULE__{} = cmd), do: %{cmd | no_cache: true}
  def pull(%__MODULE__{} = cmd), do: %{cmd | pull: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def parallel(%__MODULE__{} = cmd), do: %{cmd | parallel: true}

  def build_arg(%__MODULE__{} = cmd, key, value) do
    %{cmd | build_args: cmd.build_args ++ [{to_string(key), to_string(value)}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["build"])
    |> add_flag(cmd.no_cache, "--no-cache")
    |> add_flag(cmd.pull, "--pull")
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.parallel, "--parallel")
    |> add_repeat(cmd.build_args, fn {k, v} -> ["--build-arg", "#{k}=#{v}"] end)
    |> Kernel.++(cmd.services)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
