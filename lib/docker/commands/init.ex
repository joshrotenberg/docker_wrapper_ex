defmodule Docker.Commands.Init do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker init`.
  """

  @behaviour Docker.Command

  defstruct []

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  @impl true
  def args(%__MODULE__{}), do: ["init"]

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
