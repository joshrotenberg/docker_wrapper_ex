defmodule Docker.Commands.Context.Inspect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker context inspect`.
  """

  @behaviour Docker.Command

  @enforce_keys [:names]
  defstruct [:names]

  @type t :: %__MODULE__{}

  def new(name) when is_binary(name), do: %__MODULE__{names: [name]}
  def new(names) when is_list(names), do: %__MODULE__{names: names}

  @impl true
  def args(%__MODULE__{} = cmd), do: ["context", "inspect"] ++ cmd.names

  @impl true
  def parse_output(stdout, 0) do
    case Jason.decode(stdout) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {:json_parse_error, reason}}
    end
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
