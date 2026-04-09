defmodule Docker.Commands.Volume.Inspect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker volume inspect`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @type t :: %__MODULE__{
          volumes: [String.t()],
          format: String.t() | nil
        }

  @enforce_keys [:volumes]
  defstruct [:volumes, :format]

  def new(volume) when is_binary(volume), do: %__MODULE__{volumes: [volume]}
  def new(volumes) when is_list(volumes), do: %__MODULE__{volumes: volumes}

  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["volume", "inspect"]
    |> add_opt(cmd.format, "--format")
    |> Kernel.++(cmd.volumes)
  end

  @impl true
  def parse_output(stdout, 0) do
    case Jason.decode(stdout) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {:json_parse_error, reason}}
    end
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
