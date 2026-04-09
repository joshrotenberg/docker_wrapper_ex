defmodule Docker.Commands.Manifest.Inspect do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker manifest inspect`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3]

  @enforce_keys [:manifest_list]
  defstruct [:manifest_list, verbose: false, insecure: false]

  @type t :: %__MODULE__{}

  def new(manifest_list), do: %__MODULE__{manifest_list: manifest_list}

  def verbose(%__MODULE__{} = cmd), do: %{cmd | verbose: true}
  def insecure(%__MODULE__{} = cmd), do: %{cmd | insecure: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["manifest", "inspect"]
    |> add_flag(cmd.verbose, "--verbose")
    |> add_flag(cmd.insecure, "--insecure")
    |> Kernel.++([cmd.manifest_list])
  end

  @impl true
  def parse_output(stdout, 0) do
    case Jason.decode(stdout) do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:ok, stdout}
    end
  end

  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
