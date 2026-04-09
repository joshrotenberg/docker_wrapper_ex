defmodule Docker.Commands.Generic do
  @moduledoc """
  Escape hatch for running arbitrary Docker commands.

  Use this when there's no typed command module for what you need.

  ## Examples

      Docker.Commands.Generic.new(["system", "events", "--filter", "type=container"])
      |> Docker.generic()

  """

  @behaviour Docker.Command

  @enforce_keys [:args]
  defstruct [:args]

  @type t :: %__MODULE__{args: [String.t()]}

  @doc "Creates a generic command from a list of arguments."
  @spec new([String.t()]) :: t()
  def new(args) when is_list(args), do: %__MODULE__{args: args}

  @impl true
  def args(%__MODULE__{} = cmd), do: cmd.args

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
