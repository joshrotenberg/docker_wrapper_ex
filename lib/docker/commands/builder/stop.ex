defmodule Docker.Commands.Builder.Stop do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx stop`.
  """

  @behaviour Docker.Command

  defstruct [:name]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}
  def new(name), do: %__MODULE__{name: name}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base = ["buildx", "stop"]
    if cmd.name, do: base ++ [cmd.name], else: base
  end

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
