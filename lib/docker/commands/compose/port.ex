defmodule Docker.Commands.Compose.Port do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker compose port`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]
  require Docker.Commands.Compose.Common
  alias Docker.Commands.Compose.Common

  defstruct Common.compose_fields(
              service: nil,
              private_port: nil,
              protocol: nil,
              index: nil
            )

  @type t :: %__MODULE__{}

  def new(service, private_port) do
    %__MODULE__{service: service, private_port: to_string(private_port)}
  end

  def file(%__MODULE__{} = cmd, f), do: %{cmd | files: cmd.files ++ [f]}
  def project_name(%__MODULE__{} = cmd, n), do: %{cmd | project_name: n}
  def protocol(%__MODULE__{} = cmd, p), do: %{cmd | protocol: p}
  def index(%__MODULE__{} = cmd, i), do: %{cmd | index: i}

  @impl true
  def args(%__MODULE__{} = cmd) do
    Common.compose_prefix(cmd)
    |> Kernel.++(["port"])
    |> add_opt(cmd.protocol, "--protocol")
    |> add_opt(cmd.index && to_string(cmd.index), "--index")
    |> Kernel.++([cmd.service, cmd.private_port])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
