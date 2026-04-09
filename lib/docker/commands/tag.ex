defmodule Docker.Commands.Tag do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker tag`.
  """

  @behaviour Docker.Command

  @type t :: %__MODULE__{
          source: String.t(),
          target: String.t()
        }

  @enforce_keys [:source, :target]
  defstruct [:source, :target]

  def new(source, target), do: %__MODULE__{source: source, target: target}

  @impl true
  def args(%__MODULE__{} = cmd), do: ["tag", cmd.source, cmd.target]

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
