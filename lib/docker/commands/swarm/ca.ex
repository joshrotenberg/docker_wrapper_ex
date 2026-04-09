defmodule Docker.Commands.Swarm.Ca do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker swarm ca`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  defstruct [:cert_expiry, :external_ca, rotate: false, detach: false, quiet: false]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def rotate(%__MODULE__{} = cmd), do: %{cmd | rotate: true}
  def detach(%__MODULE__{} = cmd), do: %{cmd | detach: true}
  def quiet(%__MODULE__{} = cmd), do: %{cmd | quiet: true}
  def cert_expiry(%__MODULE__{} = cmd, c), do: %{cmd | cert_expiry: c}
  def external_ca(%__MODULE__{} = cmd, e), do: %{cmd | external_ca: e}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["swarm", "ca"]
    |> add_flag(cmd.rotate, "--rotate")
    |> add_flag(cmd.detach, "--detach")
    |> add_flag(cmd.quiet, "-q")
    |> add_opt(cmd.cert_expiry, "--cert-expiry")
    |> add_opt(cmd.external_ca, "--external-ca")
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
