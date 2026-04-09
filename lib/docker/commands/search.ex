defmodule Docker.Commands.Search do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker search`.

  Uses `--format json` for machine-readable output.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          term: String.t(),
          limit: non_neg_integer() | nil,
          no_trunc: boolean(),
          filters: [String.t()]
        }

  @enforce_keys [:term]
  defstruct [:term, :limit, no_trunc: false, filters: []]

  def new(term), do: %__MODULE__{term: term}

  def limit(%__MODULE__{} = cmd, n), do: %{cmd | limit: n}
  def no_trunc(%__MODULE__{} = cmd), do: %{cmd | no_trunc: true}
  def filter(%__MODULE__{} = cmd, f), do: %{cmd | filters: cmd.filters ++ [f]}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["search", "--format", "json"]
    |> add_flag(cmd.no_trunc, "--no-trunc")
    |> add_opt(cmd.limit && to_string(cmd.limit), "--limit")
    |> add_repeat(cmd.filters, fn f -> ["--filter", f] end)
    |> Kernel.++([cmd.term])
  end

  @impl true
  def parse_output(stdout, 0) do
    results =
      stdout
      |> String.split("\n", trim: true)
      |> Enum.map(&Jason.decode!/1)

    {:ok, results}
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
