defmodule Docker.Commands.Manifest.Push do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker manifest push`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:manifest_list]
  defstruct [:manifest_list, purge: false, insecure: false]

  @type t :: %__MODULE__{}

  def new(manifest_list), do: %__MODULE__{manifest_list: manifest_list}

  def purge(%__MODULE__{} = cmd), do: %{cmd | purge: true}
  def insecure(%__MODULE__{} = cmd), do: %{cmd | insecure: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["manifest", "push"]
    |> add_flag(cmd.purge, "--purge")
    |> add_flag(cmd.insecure, "--insecure")
    |> Kernel.++([cmd.manifest_list])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
