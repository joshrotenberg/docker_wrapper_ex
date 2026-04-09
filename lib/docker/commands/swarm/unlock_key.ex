defmodule Docker.Commands.Swarm.UnlockKey do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm unlock-key`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  defstruct quiet: false, rotate: false

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def rotate(%__MODULE__{} = cmd), do: %{cmd | rotate: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "unlock-key"]
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.rotate, "--rotate")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
