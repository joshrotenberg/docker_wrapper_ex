defmodule Docker.Commands.Import do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker import`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          source: String.t(),
          repository: String.t() | nil,
          message: String.t() | nil,
          changes: [String.t()]
        }

  @enforce_keys [:source]
  defstruct [:source, :repository, :message, changes: []]

  def new(source), do: %__MODULE__{source: source}

  def repository(%__MODULE__{} = cmd, r), do: %{cmd | repository: r}
  def message(%__MODULE__{} = cmd, m), do: %{cmd | message: m}
  def change(%__MODULE__{} = cmd, c), do: %{cmd | changes: cmd.changes ++ [c]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["import"]
      |> add_opt(cmd.message, "-m")
      |> add_repeat(cmd.changes, fn c -> ["--change", c] end)
      |> Kernel.++([cmd.source])

    if cmd.repository, do: base ++ [cmd.repository], else: base
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
