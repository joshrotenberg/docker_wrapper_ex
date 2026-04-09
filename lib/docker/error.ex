defmodule Docker.Error do
  @moduledoc """
  Error returned when a Docker command fails.
  """

  @type t :: %__MODULE__{
          command: String.t(),
          exit_code: non_neg_integer(),
          message: String.t()
        }

  defexception [:command, :exit_code, :message]

  @impl true
  def message(%__MODULE__{} = error) do
    "docker command failed (exit #{error.exit_code}): #{error.message}"
  end
end
