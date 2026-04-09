defmodule Docker.ContainerId do
  @moduledoc """
  A Docker container ID with both full and short forms.
  """

  @type t :: %__MODULE__{
          full: String.t(),
          short: String.t()
        }

  defstruct [:full, :short]

  @doc """
  Parses a container ID from Docker output (typically a full 64-char hex string).

  ## Examples

      iex> Docker.ContainerId.parse("abc123def456789\\n")
      %Docker.ContainerId{full: "abc123def456789", short: "abc123de"}

  """
  @spec parse(String.t()) :: t()
  def parse(raw) do
    full = String.trim(raw)
    short = String.slice(full, 0, 8)
    %__MODULE__{full: full, short: short}
  end
end
