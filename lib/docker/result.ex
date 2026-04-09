defmodule Docker.Result do
  @moduledoc """
  The raw result of a successful Docker command execution.
  """

  @type t :: %__MODULE__{
          stdout: String.t(),
          exit_code: non_neg_integer()
        }

  defstruct [:stdout, :exit_code]
end
