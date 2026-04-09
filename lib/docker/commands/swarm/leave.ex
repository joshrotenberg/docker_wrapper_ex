defmodule Docker.Commands.Swarm.Leave do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm leave`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  defstruct force: false

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "leave"]
    |> add_flag(cmd.force, "--force")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
