defmodule Docker.Commands.System.Df do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker system df`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  defstruct [:format, verbose: false]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def verbose(%__MODULE__{} = cmd), do: %{cmd | verbose: true}
  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["system", "df"]
    |> add_flag(cmd.verbose, "-v")
    |> add_opt(cmd.format, "--format")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
