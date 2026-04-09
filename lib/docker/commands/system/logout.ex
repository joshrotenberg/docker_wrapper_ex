defmodule Docker.Commands.System.Logout do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker logout`.
  """

  @behaviour Docker.Command

  defstruct [:server]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}
  def new(server), do: %__MODULE__{server: server}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base = ["logout"]
    if cmd.server, do: base ++ [cmd.server], else: base
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
