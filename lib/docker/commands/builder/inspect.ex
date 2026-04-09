defmodule Docker.Commands.Builder.Inspect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx inspect`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  defstruct [:name, bootstrap: false]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}
  def new(name), do: %__MODULE__{name: name}

  def bootstrap(%__MODULE__{} = cmd), do: %{cmd | bootstrap: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["buildx", "inspect"]
      |> add_flag(cmd.bootstrap, "--bootstrap")

    if cmd.name, do: base ++ [cmd.name], else: base
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
