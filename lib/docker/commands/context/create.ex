defmodule Docker.Commands.Context.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker context create`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @enforce_keys [:name]
  defstruct [:name, :description, :docker]

  @type t :: %__MODULE__{}

  def new(name), do: %__MODULE__{name: name}

  def description(%__MODULE__{} = cmd, d), do: %{cmd | description: d}
  def docker(%__MODULE__{} = cmd, d), do: %{cmd | docker: d}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["context", "create"]
    |> add_opt(cmd.description, "--description")
    |> add_opt(cmd.docker, "--docker")
    |> Kernel.++([cmd.name])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
