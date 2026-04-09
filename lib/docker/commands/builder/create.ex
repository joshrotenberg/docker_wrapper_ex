defmodule Docker.Commands.Builder.Create do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker buildx create`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  @enforce_keys []
  defstruct [:name, :driver, :platform, :node, :config_file, use: false, bootstrap: false]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def name(%__MODULE__{} = cmd, n), do: %{cmd | name: n}
  def driver(%__MODULE__{} = cmd, d), do: %{cmd | driver: d}
  def platform(%__MODULE__{} = cmd, p), do: %{cmd | platform: p}
  def node_name(%__MODULE__{} = cmd, n), do: %{cmd | node: n}
  def config_file(%__MODULE__{} = cmd, c), do: %{cmd | config_file: c}
  def use(%__MODULE__{} = cmd), do: %{cmd | use: true}
  def bootstrap(%__MODULE__{} = cmd), do: %{cmd | bootstrap: true}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["buildx", "create"]
      |> add_opt(cmd.name, "--name")
      |> add_opt(cmd.driver, "--driver")
      |> add_opt(cmd.platform, "--platform")
      |> add_opt(cmd.node, "--node")
      |> add_opt(cmd.config_file, "--config")
      |> add_flag(cmd.use, "--use")
      |> add_flag(cmd.bootstrap, "--bootstrap")

    base
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
