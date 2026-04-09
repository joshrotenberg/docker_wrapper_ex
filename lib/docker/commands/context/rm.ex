defmodule Docker.Commands.Context.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker context rm`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:names]
  defstruct [:names, force: false]

  @type t :: %__MODULE__{}

  def new(name) when is_binary(name), do: %__MODULE__{names: [name]}
  def new(names) when is_list(names), do: %__MODULE__{names: names}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["context", "rm"]
    |> add_flag(cmd.force, "-f")
    |> Kernel.++(cmd.names)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
