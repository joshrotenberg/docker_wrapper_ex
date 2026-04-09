defmodule Docker.Commands.Kill do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker kill`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @type t :: %__MODULE__{
          containers: [String.t()],
          signal: String.t() | nil
        }

  @enforce_keys [:containers]
  defstruct [:signal, :containers]

  def new(container) when is_binary(container), do: %__MODULE__{containers: [container]}
  def new(containers) when is_list(containers), do: %__MODULE__{containers: containers}

  def signal(%__MODULE__{} = cmd, s), do: %{cmd | signal: s}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["kill"]
    |> add_opt(cmd.signal, "--signal")
    |> Kernel.++(cmd.containers)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
