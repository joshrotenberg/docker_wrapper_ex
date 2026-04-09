defmodule Docker.Commands.Save do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker save`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @type t :: %__MODULE__{
          images: [String.t()],
          output: String.t() | nil
        }

  @enforce_keys [:images]
  defstruct [:images, :output]

  def new(image) when is_binary(image), do: %__MODULE__{images: [image]}
  def new(images) when is_list(images), do: %__MODULE__{images: images}

  def output(%__MODULE__{} = cmd, path), do: %{cmd | output: path}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["save"]
    |> add_opt(cmd.output, "-o")
    |> Kernel.++(cmd.images)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
