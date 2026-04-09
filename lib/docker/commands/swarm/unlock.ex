defmodule Docker.Commands.Swarm.Unlock do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm unlock`.
  """

  @behaviour Docker.Command

  defstruct []

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  @impl true
  def args(%__MODULE__{}), do: ["swarm", "unlock"]

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
