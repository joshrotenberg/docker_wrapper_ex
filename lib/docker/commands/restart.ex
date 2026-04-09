defmodule Docker.Commands.Restart do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker restart`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @type t :: %__MODULE__{
          containers: [String.t()],
          time: non_neg_integer() | nil
        }

  @enforce_keys [:containers]
  defstruct [:time, :containers]

  def new(container) when is_binary(container), do: %__MODULE__{containers: [container]}
  def new(containers) when is_list(containers), do: %__MODULE__{containers: containers}

  def time(%__MODULE__{} = cmd, t), do: %{cmd | time: t}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["restart"]
    |> add_opt(cmd.time && to_string(cmd.time), "-t")
    |> Kernel.++(cmd.containers)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
