defmodule Docker.Commands.Manifest.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker manifest create`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:manifest_list, :manifests]
  defstruct [:manifest_list, :manifests, amend: false, insecure: false]

  @type t :: %__MODULE__{}

  def new(manifest_list, manifests) when is_list(manifests) do
    %__MODULE__{manifest_list: manifest_list, manifests: manifests}
  end

  def amend(%__MODULE__{} = cmd), do: %{cmd | amend: true}
  def insecure(%__MODULE__{} = cmd), do: %{cmd | insecure: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["manifest", "create"]
    |> add_flag(cmd.amend, "--amend")
    |> add_flag(cmd.insecure, "--insecure")
    |> Kernel.++([cmd.manifest_list])
    |> Kernel.++(cmd.manifests)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
