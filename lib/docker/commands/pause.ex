defmodule Docker.Commands.Pause do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker pause`.
  """

  @behaviour Docker.Command

  @type t :: %__MODULE__{containers: [String.t()]}

  @enforce_keys [:containers]
  defstruct [:containers]

  def new(container) when is_binary(container), do: %__MODULE__{containers: [container]}
  def new(containers) when is_list(containers), do: %__MODULE__{containers: containers}

  @impl true
  def args(%__MODULE__{} = cmd), do: ["pause"] ++ cmd.containers

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
