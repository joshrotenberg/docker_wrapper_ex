defmodule Docker.Commands.Load do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker load`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  @type t :: %__MODULE__{
          input: String.t() | nil,
          quiet: boolean()
        }

  defstruct [:input, quiet: false]

  def new, do: %__MODULE__{}
  def new(input), do: %__MODULE__{input: input}

  def input(%__MODULE__{} = cmd, path), do: %{cmd | input: path}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["load"]
    |> add_flag(cmd.quiet, "-q")
    |> add_opt(cmd.input, "-i")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
