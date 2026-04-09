defmodule Docker.Commands.Volume.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker volume create`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          name: String.t() | nil,
          driver: String.t() | nil,
          labels: [{String.t(), String.t()}],
          opts: [{String.t(), String.t()}]
        }

  defstruct [:name, :driver, labels: [], opts: []]

  def new, do: %__MODULE__{}
  def new(name), do: %__MODULE__{name: name}

  def driver(%__MODULE__{} = cmd, d), do: %{cmd | driver: d}

  def label(%__MODULE__{} = cmd, key, value) do
    %{cmd | labels: cmd.labels ++ [{to_string(key), to_string(value)}]}
  end

  def opt(%__MODULE__{} = cmd, key, value) do
    %{cmd | opts: cmd.opts ++ [{to_string(key), to_string(value)}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["volume", "create"]
      |> add_opt(cmd.driver, "--driver")
      |> add_repeat(cmd.labels, fn {k, v} -> ["--label", "#{k}=#{v}"] end)
      |> add_repeat(cmd.opts, fn {k, v} -> ["-o", "#{k}=#{v}"] end)

    if cmd.name, do: base ++ [cmd.name], else: base
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
