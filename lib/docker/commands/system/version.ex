defmodule Docker.Commands.System.Version do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker version`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  defstruct [:format]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}
  def json(%__MODULE__{} = cmd), do: %{cmd | format: "json"}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["version"]
    |> add_opt(cmd.format, "--format")
  end

  @impl true
  def parse_output(stdout, 0) do
    case Jason.decode(stdout) do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:ok, stdout}
    end
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
