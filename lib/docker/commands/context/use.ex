defmodule Docker.Commands.Context.Use do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker context use`.
  """

  @behaviour Docker.Command

  @enforce_keys [:name]
  defstruct [:name]

  @type t :: %__MODULE__{}

  def new(name), do: %__MODULE__{name: name}

  @impl true
  def args(%__MODULE__{} = cmd), do: ["context", "use", cmd.name]

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
