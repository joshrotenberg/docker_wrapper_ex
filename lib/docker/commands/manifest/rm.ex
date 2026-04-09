defmodule Docker.Commands.Manifest.Rm do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker manifest rm`.
  """

  @behaviour Docker.Command

  @enforce_keys [:manifest_lists]
  defstruct [:manifest_lists]

  @type t :: %__MODULE__{}

  def new(list) when is_binary(list), do: %__MODULE__{manifest_lists: [list]}
  def new(lists) when is_list(lists), do: %__MODULE__{manifest_lists: lists}

  @impl true
  def args(%__MODULE__{} = cmd), do: ["manifest", "rm"] ++ cmd.manifest_lists

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
