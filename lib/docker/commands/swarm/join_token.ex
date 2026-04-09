defmodule Docker.Commands.Swarm.JoinToken do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm join-token`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:role]
  defstruct [:role, quiet: false, rotate: false]

  @type t :: %__MODULE__{}

  def new(role) when role in ~w(worker manager), do: %__MODULE__{role: role}

  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def rotate(%__MODULE__{} = cmd), do: %{cmd | rotate: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "join-token"]
    |> add_flag(cmd.quiet, "-q")
    |> add_flag(cmd.rotate, "--rotate")
    |> Kernel.++([cmd.role])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
