defmodule Docker.Commands.Pull do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker pull`.

  ## Examples

      import Docker.Commands.Pull

      "nginx:alpine"
      |> new()
      |> platform("linux/amd64")
      |> Docker.pull()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  @type t :: %__MODULE__{
          image: String.t(),
          all_tags: boolean(),
          platform: String.t() | nil,
          quiet: boolean()
        }

  @enforce_keys [:image]
  defstruct [:image, :platform, all_tags: false, quiet: false]

  def new(image), do: %__MODULE__{image: image}

  def all_tags(%__MODULE__{} = cmd), do: %{cmd | all_tags: true}
  def platform(%__MODULE__{} = cmd, p), do: %{cmd | platform: p}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["pull"]
    |> add_flag(cmd.all_tags, "-a")
    |> add_flag(cmd.quiet, "-q")
    |> add_opt(cmd.platform, "--platform")
    |> Kernel.++([cmd.image])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
