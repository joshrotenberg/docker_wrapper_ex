defmodule Docker.Commands.Rmi do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker rmi`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          images: [String.t()],
          force: boolean(),
          no_prune: boolean()
        }

  @enforce_keys [:images]
  defstruct [:images, force: false, no_prune: false]

  def new(image) when is_binary(image), do: %__MODULE__{images: [image]}
  def new(images) when is_list(images), do: %__MODULE__{images: images}

  def force(%__MODULE__{} = cmd), do: %{cmd | force: true}
  def no_prune(%__MODULE__{} = cmd), do: %{cmd | no_prune: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["rmi"]
    |> add_flag(cmd.force, "-f")
    |> add_flag(cmd.no_prune, "--no-prune")
    |> Kernel.++(cmd.images)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
