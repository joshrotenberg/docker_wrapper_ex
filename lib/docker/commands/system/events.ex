defmodule Docker.Commands.System.Events do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker events`.

  Best used with `Docker.Stream` for real-time event monitoring.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3, add_repeat: 3]

  defstruct [:since, :until_time, :format, filters: []]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def since(%__MODULE__{} = cmd, s), do: %{cmd | since: s}
  def until_time(%__MODULE__{} = cmd, u), do: %{cmd | until_time: u}
  def format(%__MODULE__{} = cmd, f), do: %{cmd | format: f}
  def json(%__MODULE__{} = cmd), do: %{cmd | format: "json"}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["events"]
    |> add_opt(cmd.since, "--since")
    |> add_opt(cmd.until_time, "--until")
    |> add_opt(cmd.format, "--format")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
