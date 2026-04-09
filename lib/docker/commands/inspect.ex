defmodule Docker.Commands.Inspect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker inspect`.

  Returns parsed JSON output as a list of maps.

  ## Examples

      import Docker.Commands.Inspect

      "my-container"
      |> new()
      |> Docker.inspect_cmd()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @type t :: %__MODULE__{
          targets: [String.t()],
          type: String.t() | nil,
          format: String.t() | nil
        }

  @enforce_keys [:targets]
  defstruct [:type, :format, :targets]

  def new(target) when is_binary(target), do: %__MODULE__{targets: [target]}
  def new(targets) when is_list(targets), do: %__MODULE__{targets: targets}

  def type(%__MODULE__{} = cmd, t), do: %{cmd | type: t}
  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["inspect"]
    |> add_opt(cmd.type, "--type")
    |> add_opt(cmd.format, "--format")
    |> Kernel.++(cmd.targets)
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
