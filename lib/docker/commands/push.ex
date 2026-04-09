defmodule Docker.Commands.Push do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker push`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @type t :: %__MODULE__{
          image: String.t(),
          all_tags: boolean(),
          quiet: boolean()
        }

  @enforce_keys [:image]
  defstruct [:image, all_tags: false, quiet: false]

  def new(image), do: %__MODULE__{image: image}

  def all_tags(%__MODULE__{} = cmd), do: %{cmd | all_tags: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["push"]
    |> add_flag(cmd.all_tags, "-a")
    |> add_flag(cmd.quiet, "-q")
    |> Kernel.++([cmd.image])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
