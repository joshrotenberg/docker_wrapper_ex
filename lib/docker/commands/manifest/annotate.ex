defmodule Docker.Commands.Manifest.Annotate do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker manifest annotate`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  @enforce_keys [:manifest_list, :image]
  defstruct [:manifest_list, :image, :arch, :os, :os_version, :os_features, :variant]

  @type t :: %__MODULE__{}

  def new(manifest_list, image), do: %__MODULE__{manifest_list: manifest_list, image: image}

  def arch(%__MODULE__{} = cmd, a), do: %{cmd | arch: a}
  def os(%__MODULE__{} = cmd, o), do: %{cmd | os: o}
  def os_version(%__MODULE__{} = cmd, v), do: %{cmd | os_version: v}
  def os_features(%__MODULE__{} = cmd, f), do: %{cmd | os_features: f}
  def variant(%__MODULE__{} = cmd, v), do: %{cmd | variant: v}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["manifest", "annotate"]
    |> add_opt(cmd.arch, "--arch")
    |> add_opt(cmd.os, "--os")
    |> add_opt(cmd.os_version, "--os-version")
    |> add_opt(cmd.os_features, "--os-features")
    |> add_opt(cmd.variant, "--variant")
    |> Kernel.++([cmd.manifest_list, cmd.image])
  end

  @impl true
  def parse_output(_stdout, 0), do: {:ok, :done}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
